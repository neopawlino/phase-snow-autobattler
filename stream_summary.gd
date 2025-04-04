extends Control

class_name StreamSummary

signal continue_button_pressed

enum StreamResult {
	WIN,
	LOSE,
	DRAW
}

@export var views_label : Label
@export var viewers_label : Label
@export var subscribers_label : Label
@export var subscribers_container : Control
@export var members_label : Label
@export var members_container : Control

@export var overlay : CanvasItem

@export var stream_finished_container : Control
@export var revenue_breakdown_container : Control

var stream_finished_orig_position : Vector2
var revenue_breakdown_orig_position : Vector2

func _ready() -> void:
	GlobalSignals.stream_ended.connect(show_stream_summary)
	self.stream_finished_orig_position = self.stream_finished_container.global_position
	self.revenue_breakdown_orig_position = self.revenue_breakdown_container.global_position


func show_stream_summary(result: StreamResult, money: int, income: int = 0, hp_gain: int = 0):
	self.update_stream_finished()
	self.update_revenue_breakdown()
	self.show_anim()


func update_stream_finished():
	self.views_label.text = "%d" % GameState.stream_manager.views
	self.viewers_label.text = "%d" % GameState.stream_manager.peak_viewers
	self.subscribers_label.text = "%d" % GameState.stream_manager.new_subscribers
	self.subscribers_container.visible = GameState.stream_manager.new_subscribers > 0
	self.members_label.text = "%d" % GameState.stream_manager.new_members
	self.members_container.visible = GameState.stream_manager.new_members > 0


func update_revenue_breakdown():
	pass


func show_anim():
	self.overlay.modulate.a = 0
	var tween := self.create_tween()
	tween.tween_property(self.overlay, "modulate:a", 1.0, 0.5)
	self.stream_finished_container.global_position.y = stream_finished_orig_position.y + 1000
	tween.parallel().tween_property(self.stream_finished_container, "global_position:y", stream_finished_orig_position.y, 0.5).set_trans(Tween.TRANS_QUAD)
	self.revenue_breakdown_container.global_position.y = revenue_breakdown_orig_position.y + 1000
	tween.tween_property(self.revenue_breakdown_container, "global_position:y", revenue_breakdown_orig_position.y, 0.5).set_trans(Tween.TRANS_QUAD)
	self.show()


func _on_button_pressed() -> void:
	GlobalSignals.stream_results_confirmed.emit()
	self.hide_anim()


func hide_anim():
	var tween := self.create_tween()
	tween.tween_property(self.overlay, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(self.stream_finished_container, "global_position:y", stream_finished_orig_position.y + 1000, 0.5).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(self.revenue_breakdown_container, "global_position:y", revenue_breakdown_orig_position.y + 1000, 0.5).set_trans(Tween.TRANS_QUAD)

	tween.tween_callback(self.hide)
