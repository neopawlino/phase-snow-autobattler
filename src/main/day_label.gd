extends Label


func _ready() -> void:
	GameState.round_number_changed.connect(update_day)
	update_day(GameState.round_number)


func update_day(day : int) -> void:
	self.text = "Day %d" % day
