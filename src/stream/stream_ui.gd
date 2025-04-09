extends Control

@export var stream_manager : StreamManager

@export var viewer_goal : Label
@export var views : Label
@export var views_per_sec : Label
@export var viewer_retention : Label
@export var viewers : Label
@export var subscriber_rate : Label
@export var subscribers : Label
@export var member_rate : Label
@export var members : Label


func _ready() -> void:
	stream_manager.viewer_goal_changed.connect(update_viewer_goal)
	stream_manager.views_changed.connect(update_views)
	stream_manager.views_per_sec_changed.connect(update_views_per_sec)
	stream_manager.viewer_retention_changed.connect(update_viewer_retention)
	stream_manager.viewers_changed.connect(update_viewers)
	stream_manager.subscriber_rate_changed.connect(update_subscriber_rate)
	GameState.subscribers_changed.connect(update_subscribers)
	stream_manager.member_rate_changed.connect(update_member_rate)
	GameState.members_changed.connect(update_members)

	GlobalSignals.stream_started.connect(show_anim)
	GlobalSignals.stream_started.connect(update_all)
	GlobalSignals.stream_ended.connect(func(_goal_met : bool): hide_anim())


func show_anim():
	self.modulate = Color(Color.WHITE, 0)
	self.show()
	var tween := self.create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.5).set_trans(Tween.TRANS_SINE)


func hide_anim():
	var tween := self.create_tween()
	tween.tween_property(self, "modulate", Color(Color.WHITE, 0), 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(self.hide)


func update_all():
	update_viewer_goal(stream_manager.viewer_goal)
	update_views(stream_manager.views)
	update_views_per_sec(stream_manager.views_per_sec)
	update_viewer_retention(stream_manager.viewer_retention)
	update_viewers(stream_manager.viewers)
	update_subscriber_rate(stream_manager.subscriber_rate)
	update_subscribers(GameState.subscribers)
	update_member_rate(stream_manager.member_rate)
	update_members(GameState.members)


func update_viewer_goal(amt : float):
	viewer_goal.text = "Viewer Goal: %s" % StringUtil.format_number(amt)


func update_views(amt : float):
	views.text = "%s" % StringUtil.format_number(amt)


func update_views_per_sec(amt : float):
	views_per_sec.text = "(%s/sec)" % StringUtil.format_number(amt)


func update_viewer_retention(amt : float):
	viewer_retention.text = "(%d%%)" % (amt * 100.0)


func update_viewers(amt : float):
	viewers.text = "%s" % StringUtil.format_number(amt)


func update_subscriber_rate(amt : float):
	subscriber_rate.text = "(%d%%)" % (amt * 100.0)


func update_subscribers(amt : float):
	subscribers.text = "%s" % StringUtil.format_number(amt)


func update_member_rate(amt : float):
	member_rate.text = "(%d%%)" % (amt * 100.0)


func update_members(amt : float):
	members.text = "%s" % StringUtil.format_number(amt)
