extends Label

func _ready() -> void:
	GameState.total_earnings_changed.connect(update_text)
	update_text(GameState.total_earnings)


func update_text(val : float):
	self.text = "%s" % StringUtil.format_money(val)
