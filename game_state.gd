extends Node

var slots : CharacterSlots

var is_dragging : bool = false
# we can swap when we're dragging a character already in our team, but not from the shop
var drag_can_swap : bool = false
var drag_original_char_slot : CharacterSlot
var drag_end_char_slot : CharacterSlot

var paused : bool = false:
	set(val):
		paused = val
		paused_changed.emit(val)
signal paused_changed(is_paused : bool)
