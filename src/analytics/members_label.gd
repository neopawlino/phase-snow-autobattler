extends Label

func _ready() -> void:
	GameState.members_changed.connect(update_text)
	update_text(GameState.members)


func update_text(val : float):
	self.text = "%d" % val
