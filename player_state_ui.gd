extends Control

@onready var hp_label : Label = %HPLabel
@onready var money_label : Label = %MoneyLabel
@onready var wins_label : Label = %WinsLabel
@onready var round_label : Label = %RoundLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.player_money_changed.connect(update_money_label)
	GameState.player_hp_changed.connect(update_hp_label)
	GameState.wins_changed.connect(update_wins_label)
	GameState.round_number_changed.connect(update_round_label)
	GameState.wins_needed_changed.connect(update_wins_label)
	update_money_label(GameState.player_money)
	update_hp_label(GameState.player_hp)
	update_wins_label(GameState.wins)
	update_round_label(GameState.round_number)


func update_money_label(value : float):
	money_label.text = str(value)


func update_hp_label(value : int):
	hp_label.text = str(value)


func update_wins_label(value : int):
	wins_label.text = "%s/%s" % [value, GameState.wins_needed]


func update_round_label(value : int):
	round_label.text = str(value)
