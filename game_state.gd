extends Node

var slots : CharacterSlots

var is_dragging : bool = false
# we can swap when we're dragging a character already in our team, but not from the shop
var drag_can_swap : bool = false
var drag_char : Character
var drag_original_char_slot : CharacterSlot
var drag_end_char_slot : CharacterSlot

var player_money : int:
	set(val):
		player_money = val
		player_money_changed.emit(val)

signal player_money_changed(value: int)

var max_interest : int = 5


func get_interest() -> int:
	return min(int(player_money / 5), max_interest)


var paused : bool = false:
	set(val):
		paused = val
		paused_changed.emit(val)
signal paused_changed(is_paused : bool)
