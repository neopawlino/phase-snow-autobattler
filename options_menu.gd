extends PanelContainer

class_name OptionsMenu

@export var hard_mode : CheckButton
@export var cheats : CheckButton
@export var volume_slider : Slider
@export var music_vol_slider : Slider
@export var sound_vol_slider : Slider


signal back_button_pressed



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hard_mode.button_pressed = GameState.hard_mode
	cheats.button_pressed = GameState.cheats_enabled
	volume_slider.value = Settings.get_master_volume()
	music_vol_slider.value = Settings.get_music_volume()
	sound_vol_slider.value = Settings.get_sound_volume()


func _on_back_button_pressed() -> void:
	back_button_pressed.emit()


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
