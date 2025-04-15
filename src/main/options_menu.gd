extends PanelContainer

class_name OptionsMenu

@export var hard_mode : CheckButton
@export var cheats : CheckButton
@export var volume_slider : Slider
@export var music_vol_slider : Slider
@export var sound_vol_slider : Slider

@export var fullscreen_button : CheckButton
@export var fullscreen_container : Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hard_mode.button_pressed = GameState.hard_mode
	cheats.button_pressed = GameState.cheats_enabled
	volume_slider.value = Settings.get_master_volume()
	music_vol_slider.value = Settings.get_music_volume()
	sound_vol_slider.value = Settings.get_sound_volume()
	var web := OS.has_feature("web")
	fullscreen_container.visible = not web
	if web:
		fullscreen_button.button_pressed = Settings.get_value("fullscreen", false)


func _on_hard_mode_check_toggled(toggled_on: bool) -> void:
	Settings.set_value("hard_mode", toggled_on)
	GameState.hard_mode = toggled_on


func _on_cheats_check_toggled(toggled_on: bool) -> void:
	GameState.cheats_enabled = toggled_on


func _on_h_slider_value_changed(value: float) -> void:
	Settings.set_master_volume(value)


func _on_music_vol_slider_value_changed(value: float) -> void:
	Settings.set_music_volume(value)


func _on_sound_vol_slider_value_changed(value: float) -> void:
	Settings.set_sound_volume(value)


func _on_fullscreen_check_toggled(toggled_on: bool) -> void:
	Settings.set_value("fullscreen", toggled_on)
	var new_window_mode := DisplayServer.WINDOW_MODE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_WINDOWED
	if new_window_mode != DisplayServer.window_get_mode():
		var window_id := get_tree().root.get_window().get_window_id()
		DisplayServer.window_set_mode(new_window_mode, window_id)
