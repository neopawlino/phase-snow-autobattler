extends Node

var slots : Slots
var items : Items
var combat_manager : CombatManager

var character_tooltip : CharacterTooltip

var is_dragging : bool = false:
	set(val):
		is_dragging = val
		is_dragging_changed.emit(val)
signal is_dragging_changed(value : bool)
# we can swap when we're dragging a character already in our team, but not from the shop
var drag_can_swap : bool = false
var drag_object : Node:
	set(drag_obj):
		drag_object = drag_obj
		drag_object_changed.emit(drag_obj)
signal drag_object_changed(drag_obj : Node)
var drag_original_slot : Slot
var drag_end_slot : Slot
var drag_sell_button : bool
var drag_initial_mouse_pos : Vector2

var player_money : int:
	set(val):
		player_money = val
		player_money_changed.emit(val)
signal player_money_changed(value: int)

var player_hp : int:
	set(val):
		player_hp = val
		player_hp_changed.emit(val)
signal player_hp_changed(value: int)

var max_interest : int = 5

var round_number : int:
	set(val):
		round_number = val
		round_number_changed.emit(val)
signal round_number_changed(value: int)

var wins : int:
	set(val):
		wins = val
		wins_changed.emit(val)
signal wins_changed(value: int)

var wins_needed : int:
	set(val):
		wins_needed = val
		wins_needed_changed.emit(val)
signal wins_needed_changed(value: int)


var hard_mode : bool


var cheats_enabled : bool:
	set(val):
		cheats_enabled = val
		cheats_enabled_changed.emit(val)
signal cheats_enabled_changed(value : bool)


func get_interest() -> int:
	return min(int(player_money / 5), max_interest)


func close_character_tooltip():
	GameState.character_tooltip.hide()


var paused : bool = false:
	set(val):
		paused = val
		paused_changed.emit(val)
		get_tree().paused = val
signal paused_changed(is_paused : bool)
