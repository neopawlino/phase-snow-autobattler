extends Button

@export var start_menu : Control
@export var click_sound : AudioStream


func _on_pressed() -> void:
	if click_sound:
		SoundManager.play_sound(click_sound)
	start_menu.visible = not start_menu.visible
