extends Control

class_name ResultScreen

@export var defeat_title : String = "STATUS: TERMINATED"
@export var defeat_subtitle : String = "Failed to meet viewership goal on Day %d."
@export var endless_defeat_title : String = "STATUS: GRADUATED"
@export var endless_defeat_subtitle : String = "Failed to meet viewership goal on Day %d."
@export var victory_title : String = "VICTORY!"
@export var victory_subtitle : String = "You reached 1,000,000 subscribers on Day %d."

@export var results_panel : Control
@export var overlay : CanvasItem

@export var title_label : Label
@export var subtitle_label : Label

@export var day : Label
@export var highest_views : Label
@export var highest_viewers : Label
@export var subscribers : Label
@export var members : Label
@export var total_earnings : Label

@export var restart_button : Button
@export var endless_button : Button

var panel_initial_position : Vector2


func _ready() -> void:
	self.panel_initial_position = results_panel.position
	GlobalSignals.viewer_goal_failed.connect(func():
		update_results(false)
		show_anim()
	)
	GlobalSignals.victory.connect(func():
		update_results(true)
		show_anim()
		GameState.victory_screen_shown = true
	)
	restart_button.pressed.connect(GameState.restart_game)
	endless_button.pressed.connect(hide_anim)



func show_anim():
	results_panel.position.y += 720
	overlay.modulate.a = 0
	self.show()
	var tween := self.create_tween()
	tween.tween_property(results_panel, "position", panel_initial_position, 1.0).set_trans(Tween.TRANS_QUAD)
	tween.set_parallel().tween_property(overlay, "modulate", Color.WHITE, 1.0)


func hide_anim():
	var target_pos := panel_initial_position
	target_pos.y += 720
	var tween := self.create_tween()
	tween.tween_property(results_panel, "position", target_pos, 1.0).set_trans(Tween.TRANS_QUAD)
	tween.set_parallel().tween_property(overlay, "modulate:a", 0, 1.0)
	tween.tween_callback(self.hide)


func update_results(victory : bool):
	# round number gets increased on stream results confirmed
	# we want to show the lose screen on stream end and win screen after stream results confirmed
	var day_number := GameState.round_number - 1 if victory else GameState.round_number
	if victory:
		title_label.text = victory_title
		subtitle_label.text = victory_subtitle % day_number
	elif GameState.victory_screen_shown:
		title_label.text = endless_defeat_title
		subtitle_label.text = endless_defeat_subtitle % day_number
	else:
		title_label.text = defeat_title
		subtitle_label.text = defeat_subtitle % day_number
	day.text = "%d" % day_number
	highest_views.text = StringUtil.format_number(GameState.highest_views)
	highest_viewers.text = StringUtil.format_number(GameState.highest_viewers)
	subscribers.text = StringUtil.format_number(GameState.subscribers)
	members.text = StringUtil.format_number(GameState.members)
	total_earnings.text = StringUtil.format_money(GameState.total_earnings)
	endless_button.visible = victory
