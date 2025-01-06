extends Control

@export_file("*.tscn") var main_menu : String
@export var options : Container
@export var pause_menu : Container
@export var hard_mode : CheckButton
@export var cheats : CheckButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = GameState.paused
	GameState.paused_changed.connect(on_paused_changed)
	hard_mode.button_pressed = GameState.hard_mode
	cheats.button_pressed = GameState.cheats_enabled


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		GameState.paused = not GameState.paused


func on_paused_changed(is_paused : bool):
	visible = is_paused


func _on_button_2_pressed() -> void:
	GameState.paused = false
	get_tree().change_scene_to_file(main_menu)


func _on_button_pressed() -> void:
	GameState.paused = false


func _on_options_button_pressed() -> void:
	options.visible = true
	pause_menu.visible = false


func _on_back_button_pressed() -> void:
	options.visible = false
	pause_menu.visible = true


func _on_hard_mode_check_toggled(toggled_on: bool) -> void:
	GameState.hard_mode = toggled_on


func _on_cheats_check_toggled(toggled_on: bool) -> void:
	GameState.cheats_enabled = toggled_on
