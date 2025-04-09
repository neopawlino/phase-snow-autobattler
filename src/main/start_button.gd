extends Button

@export var start_menu : Control


func _on_pressed() -> void:
	start_menu.visible = not start_menu.visible
