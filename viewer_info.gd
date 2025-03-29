extends VBoxContainer

@export var stream_manager : CombatManager

@export var viewer_goal : Label
@export var viewers : Label
@export var views_per_sec : Label

func _ready() -> void:
	stream_manager.viewer_goal_changed.connect(update_viewer_goal)
	stream_manager.viewers_changed.connect(update_viewers)
	stream_manager.views_per_sec_changed.connect(update_views_per_sec)


func update_viewer_goal(amt : float):
	viewer_goal.text = "Viewer Goal: %d" % amt


func update_viewers(amt : float):
	viewers.text = "Viewers: %d" % amt


func update_views_per_sec(amt : float):
	views_per_sec.text = "Views/sec: %d" % amt
