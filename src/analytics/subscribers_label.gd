extends Label

func _ready() -> void:
	GameState.subscribers_changed.connect(update_text)
	update_text(GameState.subscribers)


func update_text(val : float):
	self.text = "%d" % val
