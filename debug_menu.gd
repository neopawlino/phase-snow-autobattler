extends PanelContainer


@export var team_manager : TeamManager


func _on_button_pressed() -> void:
	team_manager.add_test_character()


func _on_add_xp_button_pressed() -> void:
	for slot in team_manager.slots.player_team:
		if slot.character:
			slot.character.add_xp(1)
			return
