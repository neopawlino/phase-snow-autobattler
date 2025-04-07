extends Label


func _ready() -> void:
	GameState.viewer_goal_changed.connect(update_text)
	update_text(GameState.viewer_goal)


func update_text(num : float):
	self.text = "%d" % num
