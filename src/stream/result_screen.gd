extends Control

class_name ResultScreen

@export var results_panel : Control
@export var overlay : CanvasItem

@export var day : Label
@export var highest_views : Label
@export var highest_viewers : Label
@export var subscribers : Label
@export var members : Label
@export var total_earnings : Label

var panel_initial_position : Vector2


func _ready() -> void:
	self.panel_initial_position = results_panel.position
	GlobalSignals.viewer_goal_failed.connect(show_anim)


func show_anim():
	results_panel.position.y += 720
	overlay.modulate.a = 0
	self.show()
	var tween := self.create_tween()
	tween.tween_property(results_panel, "position", panel_initial_position, 1.0).set_trans(Tween.TRANS_QUAD)
	tween.set_parallel().tween_property(overlay, "modulate", Color.WHITE, 1.0)


func _on_retry_button_pressed() -> void:
	GameState.reset()
	get_tree().reload_current_scene()
