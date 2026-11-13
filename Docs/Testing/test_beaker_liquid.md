User story: Käyttäjänä näen nesteen astiassa.
Hyväksymiskriteerit: Dekantterissa on nestettä.
Testitiedosto: test_beaker_liquid.gd
funktio

func after_test() -> void: tämä vapauttaa kaiken muistin joka neste astiat käyttää testien jälkeen

func create_container(
	fill_ml: float = 0.0,
	initial_ph: float = 7.0
) -> LiquidContainer: Tämä funktio luoo neste astian ja laittaa sille yksinkertainen shader joka se voi käytää

func test_empty_container_has_empty_mass() -> void: Tämä funktio testaa että tyhjällä astialla ei ole painoa

func test_initial_mass_matches_fill_amount() -> void: Tämä funktio testaa että neste alussa antaa oikea paino

func test_change_fill_amount_increases_volume_and_mass() -> void:  Testaa että kun sitä täytetään se täytyy ja paino muuttuu

func test_change_fill_amount_cannot_exceed_maximum() -> void: Testaa että ei pysty lisätä enemmän nestettä kun astiaan mahtuu

func test_change_fill_amount_cannot_go_below_zero() -> void: Testaa että ei pysty ottaa pois enemmän nestettä kun se on jo tyhjä käyttäen change_fill amount funktio

func test_remove_liquid_cannot_remove_more_than_exists() -> void: Testaa että ei pysty ottaa pois enemmän nestettä kun se on jo tyhjä käyttäen remove_liquid amount funktio

func test_mass_changed_signal_is_emitted_when_volume_changes() -> void: Testaa että signaali tulee kun volyymi muuttuu

func test_mass_changed_signal_is_emitted_when_adding_reagent() -> void: Testaa että signaali tulee kun lisää reagenssi

func test_mass_changed_signal_is_emitted_when_removing_liquid() -> void: Testaa että signaali tulee kun ottaa pois nestettä

Testien kirjoittaja: Dominic Nygård
