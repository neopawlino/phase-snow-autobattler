extends Control

@export var stream_manager : CombatManager

@export var viewer_goal : Label
@export var viewers : Label
@export var views_per_sec : Label
@export var subscriber_rate : Label
@export var subscribers : Label
@export var member_rate : Label
@export var members : Label


func _ready() -> void:
	stream_manager.viewer_goal_changed.connect(update_viewer_goal)
	stream_manager.viewers_changed.connect(update_viewers)
	stream_manager.views_per_sec_changed.connect(update_views_per_sec)
	stream_manager.subscriber_rate_changed.connect(update_subscriber_rate)
	GameState.subscribers_changed.connect(update_subscribers)
	stream_manager.member_rate_changed.connect(update_member_rate)
	GameState.members_changed.connect(update_members)


func update_viewer_goal(amt : float):
	viewer_goal.text = "Viewer Goal: %d" % amt


func update_viewers(amt : float):
	viewers.text = "Viewers: %d" % amt


func update_views_per_sec(amt : float):
	views_per_sec.text = "Views/sec: %d" % amt


func update_subscriber_rate(amt : float):
	subscriber_rate.text = "Subscriber Rate: %d%%" % (amt * 100.0)


func update_subscribers(amt : float):
	subscribers.text = "Subscribers: %d" % amt


func update_member_rate(amt : float):
	member_rate.text = "Member Rate: %d%%" % (amt * 100.0)


func update_members(amt : float):
	members.text = "Members: %d" % amt
