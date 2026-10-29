User story: Käyttäjänä pystyn punnitsemaan vaa'alla.

Hyväksymiskriteerit: Vaaka taarataan napista painamalla, punnittava esine lasketaan vaa'an päälle ja vaaka näyttää esineen painon.

Testitiedosto: test_scale.gd

funktio test_initial_weight_is_zero testaa että paino alussa on nolla

funktio test_add_body_adds_its_mass testaa esineen lisäessä vaa'an päälle sen paino näkyy

funktio test_add_multiple_bodies_adds_all_masses testaa monen esineen lisäessä niiden painon summa näkyy

funktio test_same_body_is_not_counted_twice testaa että esineen painoa ei lasketa kahdesti

funktio test_remove_body_removes_its_mass testaa esineen poistamista vaa'alta

funktio test_remove_body_that_is_not_on_scale_does_nothing testaa esineen joka ei ole vaa'an päällä poistamista ja että se ei vaikuta vaa'an painoon

funktio test_tare_sets_current_weight_to_zero testaa vaa'an taaraamista

funktio test_weight_after_tare_only_counts_new_weight testaa esineen lisäämistä vaa'alle sen taaraamisen jälkeen

funktio test_removing_object_after_tare_updates_weight testaa esineen poistamista vaa'alta taaraamisen jälkeen

funktio test_calculate_weight_uses_base_weight testaa että vaaka käyttää base_weight muuttujaa painoksi

funktio test_weight_changed_signal_is_emitted_when_adding testaa painon lisäyksessä signaalin lähetystä

funktio test_weight_changed_signal_is_emitted_when_removing testaa painon poistamisessa signaalin lähetystä 

funktio test_weight_changed_signal_when_taring testaa painon taarauksessa signaalin lähetystä

Testien kirjoittaja: Dominic Nygård
