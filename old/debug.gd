extends MarginContainer


func _on_button_pressed() -> void:
	if GameState.bench_slots.all_slots_full():
		return
	var talent := Character.spawn_from_character_definition(RandomUtil.all_character_definitions.pick_random())
	self.add_child(talent)
	GameState.bench_slots.push_char(talent)


func give_xp() -> void:
	GameState.main_slots.foreach_slot_obj(func(slot_obj):
		if slot_obj is Character:
			slot_obj.add_xp(1)
	)


func _on_check_button_toggled(toggled_on: bool) -> void:
	GameState.cheat_remove_level_cap = toggled_on
