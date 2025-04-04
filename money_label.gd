extends Label


func _ready() -> void:
	GameState.player_money_changed.connect(update_text)
	update_text(GameState.player_money)


func update_text(val : float):
	self.text = "$%.2f" % val
