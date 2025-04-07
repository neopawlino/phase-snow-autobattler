extends MarginContainer


func _on_button_pressed() -> void:
	if GameState.bench_slots.all_slots_full():
		return
	var talent := Character.spawn_from_character_definition(RandomUtil.all_character_definitions.pick_random())
	self.add_child(talent)
	GameState.bench_slots.push_char(talent)
