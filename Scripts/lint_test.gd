extends Node


# 1. Väärä nimeämistyyli
var PlayerHealth = 100


# 2. Väärä tyyppi
var player_name: int = "Player"


# 3. Käyttämätön muuttuja
var unused_variable := 123


# 4. Puuttuva tyyppi parametrilta
func take_damage(amount):
	PlayerHealth -= amount


# 5. Väärä palautustyyppi
func get_health() -> String:
	return PlayerHealth


# 6. Palautustyyppi puuttuu
func reset_health():
	PlayerHealth = 100


# 7. Käyttämätön parametri
func set_health(value: int) -> void:
	PlayerHealth = 100


# 8. Väärä nimeämistyyli funktiolle
func TakeDamage(amount: int) -> void:
	PlayerHealth -= amount


# 9. Epäselvä boolean-muuttujan nimi
var enabled := true


# 10. Turha vertailu booleaniin
func is_alive() -> bool:
	if enabled == true:
		return true

	return false


# 11. Mahdollisesti tarpeeton if
func has_health() -> bool:
	if PlayerHealth > 0:
		return true
	else:
		return false


# 12. Tyhjä funktio
func do_nothing() -> void:
	pass


# 13. Käyttämätön paikallinen muuttuja
func calculate_damage() -> int:
	var damage := 50
	var multiplier := 2.0

	return damage


# 14. Vääränlainen tyyppioperaatio
func invalid_operation() -> void:
	var health: int = 100
	var name: String = "Player"

	var result = health + name


# 15. Mahdollisesti alustamaton muuttuja
func uninitialized_variable() -> void:
	var value: int

	print(value)


# 16. Virheellinen propertyn käyttö
func invalid_property() -> void:
	var player := Node.new()

	print(player.non_existing_property)


# 17. Virheellinen metodikutsu
func invalid_method() -> void:
	var player := Node.new()

	player.this_method_does_not_exist()


# 18. Väärä signaalin tyyli / mahdollinen lint-ongelma
signal PlayerDied


# 19. Duplikaattinimi / varjostaminen
func shadowing_example() -> void:
	var PlayerHealth := 50

	print(PlayerHealth)

