extends Control

@export_file("*.tscn") var main_menu : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = GameState.paused
	GameState.paused_changed.connect(on_paused_changed)


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
