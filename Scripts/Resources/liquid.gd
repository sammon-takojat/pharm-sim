extends Node
class_name Liquid

var _mesh : MeshInstance3D
var _fill_amount_ml := 0.0
var _max_fill_ml := 0.0
var _shader_mat : ShaderMaterial


var _pH := 0.0
var _net_h_moles: float

func constructor(initial_ml: float, initial_ph: float, max_fill_ml: float, mesh : MeshInstance3D) -> void:
	_pH = initial_ph
	_max_fill_ml = max_fill_ml
	_mesh = mesh
	
	var source_mat = _mesh.get_active_material(0)
	if not source_mat is ShaderMaterial:
		push_error("Mesh surface 0 does not use a ShaderMaterial!")
		return
	
	_shader_mat = source_mat.duplicate() as ShaderMaterial
	
	_mesh.set_surface_override_material(0, _shader_mat)
	
	
	var aabb = _mesh.get_aabb()
	
	var center = aabb.position + aabb.size * 0.5
	var half_extents = aabb.size * 0.5

	_shader_mat.set_shader_parameter("bounds_center", center)
	_shader_mat.set_shader_parameter("bounds_half_extent", half_extents)
	
	change_fill_amount(initial_ml)
	
	var h_concentration = pow(10.0, -_pH)
	var oh_concentration = pow(10.0, _pH - 14.0)
	
	var net_concentration = h_concentration - oh_concentration
	_net_h_moles = net_concentration * (_fill_amount_ml / 1000.0)
	
	

func change_fill_amount(amount_ml: float) -> void:
	_fill_amount_ml = clamp(
		_fill_amount_ml + amount_ml,
		0.0,
		_max_fill_ml
	)
	var fill_percent = _fill_amount_ml / _max_fill_ml
	_shader_mat.set_shader_parameter("fill_amount", fill_percent)
	
	
func add_reagent(amount_ml: float, molarity: float, is_base: bool):
	var added_moles = (amount_ml / 1000.0) * molarity
	
	if is_base:
		_net_h_moles -= added_moles
	else:
		_net_h_moles += added_moles
	
	change_fill_amount(amount_ml)
	
	update_pH()
	
func remove_liquid(amount_ml: float) -> Dictionary:
	var removed_amount = min(amount_ml, _fill_amount_ml)
	
	var fraction = removed_amount / _fill_amount_ml
	
	var removed_moles = _net_h_moles * fraction
	
	_net_h_moles -= removed_moles
	change_fill_amount(-amount_ml)
	
	update_pH()
	
	return {
		"volume_ml": removed_amount,
		"net_h_moles": removed_moles
	}	

func update_pH():
	if _fill_amount_ml <= 0.0:
		_pH = 7.0
		return
	
	var volume_l = _fill_amount_ml / 1000.0
	var net_concentration = _net_h_moles / volume_l
	
	var kw = 1.0e-14
	var h_concentration = (
		net_concentration + sqrt(net_concentration * net_concentration + 4.0 * kw)
	) / 2.0
	
	_pH = -log(h_concentration) / log(10.0)
	print(_pH)
	
