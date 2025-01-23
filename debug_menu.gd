extends PanelContainer


@export var team_manager : TeamManager


func _ready() -> void:
	GameState.cheats_enabled_changed.connect(func(val: bool):
		self.visible = val
	)
	self.visible = GameState.cheats_enabled


func _on_button_pressed() -> void:
	team_manager.add_test_character()


func _on_add_xp_button_pressed() -> void:
	for slot in team_manager.slots.player_team:
		if slot.slot_obj:
			slot.slot_obj.add_xp(1)
			return


func _on_add_money_button_pressed() -> void:
	GameState.player_money += 1
