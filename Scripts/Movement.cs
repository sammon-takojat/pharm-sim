using Godot;
using System;

public partial class Movement : CharacterBody3D
{
	public float Speed = 15.0f;
	public float Gravity = 20.0f;
	public float Jump = 12.0f;

	public float CamAccel = 40.0f;
	public float MouseSense = 0.1f;

	private Vector3 direction;
	private Vector3 gravityVec;

	[Export]
	public Node3D Head { get; set; }

	private Camera3D camera;

	[Export]
	public CollisionShape3D Collider { get; set; }

	[Export]
	public Camera3D RealCamera { get; set; }


	// Movement
	public enum MoveStates
	{
		Ground,
		Air
	}

	private MoveStates currentState = MoveStates.Air;
	private MoveStates previousState = MoveStates.Air;


	// Ground
	private float FloorSnapLength = 0.4f;
	private const float FloorAccel = 7.0f;
	private const float FloorDrag = 8.0f;


	// Air
	private const float AirSnapLength = 0.1f;
	private const float AirAccel = 0.5f;
	private const float AirSpeed = 16.0f;
	private const float AirDrag = 0.1f;


	// Air Strafing
	[Export]
	public Curve AirStrafeCurve { get; set; }

	private const float MinStrafeAngle = 0.0f;
	private const float MaxStrafeAngle = 180.0f;

	[Export]
	public float AirStrafeModifier = 1.0f;


	// Jumping
	private bool canJump = true;
	private bool hasJumped = false;

	[Export]
	public float CoyoteTime = 0.2f;

	private bool jumpQueued = false;


	// Crouching
	private float fullHeight;
	private float crouchHeight;

	[Export]
	public ShapeCast3D CeilingCheck { get; set; }

	private const float HeightLerpSpeed = 10.0f;

	private float headOffset;

	private bool isCrouching = false;

	[Export]
	public float CrouchSpeed = 8.0f;

	[Export]
	public float CrouchAccel = 4.0f;


	// Camera
	[Export]
	public float ShakeMaxSpeed = 20.0f;

	[Export]
	public float Fov = 95.0f;

	[Export]
	public float SpeedFovIncrease = 5.0f;

	[Export]
	public float FovLerpSpeed = 5.0f;


	// Signals
	[Signal]
	public delegate void JustJumpedEventHandler();

	[Signal]
	public delegate void JustLandedEventHandler();


	public override void _Ready()
	{
		Input.MouseMode = Input.MouseModeEnum.Captured;

		Head = GetNode<Node3D>("Head");
		camera = GetNode<Camera3D>("Head/Camera3D");

		if (Collider != null && Collider.Shape is CapsuleShape3D capsule)
		{
			fullHeight = capsule.Height;
			crouchHeight = fullHeight / 2.0f;
		}

		if (Head != null)
			headOffset = Head.Position.Y;
	}


	public override void _Input(InputEvent @event)
	{
		if (@event is InputEventMouseMotion mouseMotion)
		{
			RotateY(Mathf.DegToRad(-mouseMotion.Relative.X * MouseSense));

			Head.RotateX(
				Mathf.DegToRad(-mouseMotion.Relative.Y * MouseSense)
			);

			Vector3 headRotation = Head.Rotation;

			headRotation.X = Mathf.Clamp(
				headRotation.X,
				Mathf.DegToRad(-89.0f),
				Mathf.DegToRad(89.0f)
			);

			Head.Rotation = headRotation;
		}
	}


	public override void _Process(double delta)
	{
		float dt = (float)delta;

		// Camera interpolation
		if (Engine.GetFramesPerSecond() > Engine.PhysicsTicksPerSecond)
		{

			Vector3 cameraPosition = camera.GlobalPosition;

			cameraPosition = cameraPosition.Lerp(
				Head.GlobalPosition,
				CamAccel * dt
			);

			camera.GlobalPosition = cameraPosition;

			Vector3 cameraRotation = camera.Rotation;

			cameraRotation.Y = Rotation.Y;
			cameraRotation.X = Head.Rotation.X;

			camera.Rotation = cameraRotation;
		}
		else
		{
			camera.GlobalTransform = Head.GlobalTransform;
		}


		// FOV
		float speedRatio = Mathf.Min(
			Velocity.Length() / ShakeMaxSpeed,
			1.0f
		);

		float targetFov = Mathf.Lerp(
			Fov,
			Fov + SpeedFovIncrease,
			speedRatio
		);

		camera.Fov = Mathf.Lerp(
			camera.Fov,
			targetFov,
			FovLerpSpeed * dt
		);
	}


	public override void _PhysicsProcess(double delta)
	{
		float dt = (float)delta;

		switch (currentState)
		{
			case MoveStates.Ground:
				Ground(dt);
				break;

			case MoveStates.Air:
				Air(dt);
				break;
		}


		// Jump
		if ((Input.IsActionJustPressed("Jump") || jumpQueued) && canJump)
		{
			canJump = false;
			hasJumped = true;
			jumpQueued = false;

			EmitSignal(SignalName.JustJumped);

			if (currentState != MoveStates.Air)
				ChangeState(MoveStates.Air);
		}
	}


	private void Ground(float delta)
	{
		isCrouching = HandleCrouch(delta);

		FloorSnapLength = 0.4f;

		gravityVec = Vector3.Zero;

		if (!isCrouching)
		{
			Move(delta, FloorAccel, FloorDrag);
		}
		else
		{
			Move(
				delta,
				CrouchAccel,
				FloorDrag
			);
		}

		GroundToAir();
	}


	private void Air(float delta)
	{
		isCrouching = HandleCrouch(
			delta,
			false,
			true
		);

		FloorSnapLength = AirSnapLength;


		if (hasJumped)
		{
			Vector3 jumpDirection =
				(GetFloorNormal() + Vector3.Up).Normalized();

			gravityVec = jumpDirection * Jump;

			hasJumped = false;
		}
		else
		{
			gravityVec = Vector3.Down * Gravity * delta;
		}


		Move(
			delta,
			AirAccel,
			AirDrag
		);


		// Landing
		if (IsOnFloor())
		{
			if (isCrouching)
			{
				ChangeState(MoveStates.Ground);
			}
			else
			{
				ChangeState(MoveStates.Ground);

				EmitSignal(SignalName.JustLanded);
			}

			canJump = true;
		}


		// Jump buffering
		if (Input.IsActionJustPressed("Jump"))
			QueueJump();
	}


	private void ChangeState(MoveStates newState)
	{
		previousState = currentState;
		currentState = newState;
	}


	private async void QueueJump()
	{
		jumpQueued = true;

		await ToSignal(
			GetTree().CreateTimer(CoyoteTime),
			SceneTreeTimer.SignalName.Timeout
		);

		jumpQueued = false;
	}


	private bool GroundToAir()
	{
		if (!IsOnFloor())
		{
			ChangeState(MoveStates.Air);

			if (canJump)
				ExecuteAfterTime(
					CoyoteTime,
					() =>
					{
						if (!IsOnFloor())
							canJump = false;
					}
				);

			return true;
		}

		return false;
	}


	private async void ExecuteAfterTime(
		float time,
		Action action
	)
	{
		await ToSignal(
			GetTree().CreateTimer(time),
			SceneTreeTimer.SignalName.Timeout
		);

		action?.Invoke();
	}


	private void ApplyForce(Vector3 force)
	{
		Velocity += force;
	}


	public void SlowMovement(float amount)
	{
		Velocity *= amount;
	}


	private bool HandleCrouch(
		float delta,
		bool forceCrouch = false,
		bool forceUncrouch = false
	)
	{
		if (Collider == null)
			return false;

		if (Collider.Shape is not CapsuleShape3D capsule)
			return false;


		float height = capsule.Height;

		bool crouching =
			Input.IsActionPressed("crouch")
			||
			(
				height < fullHeight - 0.1f
				&&
				CeilingCheck != null
				&&
				CeilingCheck.IsColliding()
			)
			||
			forceCrouch;


		if (forceUncrouch)
			crouching = false;


		if (!Mathf.IsEqualApprox(height, fullHeight) ||
			!Mathf.IsEqualApprox(height, crouchHeight))
		{
			float targetHeight =
				crouching
					? crouchHeight
					: fullHeight;

			capsule.Height = Mathf.Lerp(
				capsule.Height,
				targetHeight,
				delta * HeightLerpSpeed
			);


			Vector3 headPosition = Head.Position;

			headPosition.Y = Mathf.Lerp(
				headPosition.Y,
				crouching
					? headOffset / 2.0f
					: headOffset,
				delta * HeightLerpSpeed
			);

			Head.Position = headPosition;
		}


		return crouching;
	}


	private void Move(
		float delta,
		float accel,
		float drag,
		float movementSpeed = -1.0f
	)
	{
		if (movementSpeed < 0.0f)
			movementSpeed = Speed;


		// Keyboard input
		direction = Vector3.Zero;

		float horizontalRotation = GlobalTransform.Basis.GetEuler().Y;

		float forwardInput =
			Input.GetAxis("Up", "Down");

		float horizontalInput =
			Input.GetActionStrength("Right")
			-
			Input.GetActionStrength("Left");


		direction = new Vector3(
			horizontalInput,
			0.0f,
			forwardInput
		);


		direction = direction
			.Rotated(Vector3.Up, horizontalRotation)
			.Normalized();


		Vector3 wishVelocity =
			direction * movementSpeed;


		// Air strafing
		if (currentState == MoveStates.Air &&
			direction.Length() > 0.0f)
		{
			float angleDifference =
				Mathf.RadToDeg(
					GetHorizontalAngle(
						Velocity,
						wishVelocity
					)
				);


			float samplePoint =
				(angleDifference - MinStrafeAngle)
				/
				MaxStrafeAngle;


			if (AirStrafeCurve != null)
			{
				float curveValue =
					AirStrafeCurve.Sample(
						Mathf.Clamp(samplePoint, 0.0f, 1.0f)
					);

				wishVelocity *=
					1.0f +
					curveValue *
					AirStrafeModifier;
			}
		}


		// Crouch movement
		if (currentState == MoveStates.Ground &&
			isCrouching)
		{
			wishVelocity =
				direction * CrouchSpeed;
		}


		// Acceleration / deceleration
		if (direction.Length() > 0.0f)
		{
			Velocity = Velocity.Lerp(
				wishVelocity,
				accel * delta
			);
		}
		else
		{
			Velocity = Velocity.Lerp(
				wishVelocity,
				drag * delta
			);
		}


		// Gravity
		Velocity += gravityVec;

		MoveAndSlide();
	}


	private float GetHorizontalAngle(
		Vector3 vec1,
		Vector3 vec2
	)
	{
		vec1.Y = 0.0f;
		vec2.Y = 0.0f;

		return vec1.AngleTo(vec2);
	}
}
