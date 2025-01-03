extends Control

@onready var hp_label : Label = %HPLabel
@onready var money_label : Label = %MoneyLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.player_money_changed.connect(update_money_label)
	GameState.player_hp_changed.connect(update_hp_label)
	update_money_label(GameState.player_money)
	update_hp_label(GameState.player_hp)


func update_money_label(value : int):
	money_label.text = str(value)


func update_hp_label(value : int):
	hp_label.text = str(value)
