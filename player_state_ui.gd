extends Control

@export var money_label : Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.player_money_changed.connect(update_money_label)
	update_money_label(GameState.player_money)


func update_money_label(value : int):
	money_label.text = str(value)
