extends PanelContainer


@export var team_manager : TeamManager


func _on_button_pressed() -> void:
	team_manager.add_test_character()
