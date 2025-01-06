extends PanelContainer

class_name OptionsMenu

@export var hard_mode : CheckButton
@export var cheats : CheckButton
@export var volume_slider : Slider


signal back_button_pressed

@export var audio_bus_name := "Master"
@onready var _bus := AudioServer.get_bus_index(audio_bus_name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hard_mode.button_pressed = GameState.hard_mode
	cheats.button_pressed = GameState.cheats_enabled
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(_bus))


func _on_back_button_pressed() -> void:
	back_button_pressed.emit()


func _on_hard_mode_check_toggled(toggled_on: bool) -> void:
	GameState.hard_mode = toggled_on


func _on_cheats_check_toggled(toggled_on: bool) -> void:
	GameState.cheats_enabled = toggled_on


func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(_bus, linear_to_db(value))
