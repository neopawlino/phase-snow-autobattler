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
@export var total_revenue_label : Label

@export var overlay : CanvasItem

@export var base_revenue_label : Label
@export var ad_revenue_container : Control
@export var ad_revenue_label : Label
@export var rpm_label : Label
@export var member_revenue_container : Control
@export var member_revenue_label : Label
@export var item_revenue_container : Control
@export var item_revenue_label : Label
@export var abilities_revenue_container : Control
@export var abilities_revenue_label : Label

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
	self.views_label.text = "%s" % StringUtil.format_number(GameState.stream_manager.views)
	self.viewers_label.text = "%s" % StringUtil.format_number(GameState.stream_manager.peak_viewers)
	self.subscribers_container.visible = GameState.stream_manager.new_subscribers > 0
	self.subscribers_label.text = "%s" % StringUtil.format_number(GameState.stream_manager.new_subscribers)
	self.members_container.visible = GameState.stream_manager.new_members > 0
	self.members_label.text = "%s" % StringUtil.format_number(GameState.stream_manager.new_members)

	self.total_revenue_label.text = "$%.2f" % GameState.stream_manager.total_revenue


func update_revenue_breakdown():
	self.base_revenue_label.text = "$%.2f" % GameState.stream_manager.base_revenue

	self.ad_revenue_container.visible = GameState.stream_manager.ad_revenue > 0
	self.ad_revenue_label.text = "$%.2f" % GameState.stream_manager.ad_revenue
	self.rpm_label.text = "($%.2f per 1,000 views)" % GameState.stream_manager.ad_rpm

	self.member_revenue_container.visible = GameState.members > 0
	self.member_revenue_label.text = "$%.2f" % GameState.stream_manager.member_revenue

	# no item revenue yet
	self.item_revenue_container.visible = false

	# no abilities revenue yet
	self.abilities_revenue_container.visible = false


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
