extends Control

class_name CharacterSlot

var slot_index : int
var character : Character

@export var body : StaticBody2D


func set_pickable(pickable : bool):
	body.input_pickable = pickable


func _on_static_body_2d_mouse_entered() -> void:
	if GameState.is_dragging:
		GameState.drag_end_char_slot = self
		if GameState.drag_can_swap:
			# TODO logic for swapping characters (call a function on GameState.slots)
			pass


func _on_static_body_2d_mouse_exited() -> void:
	if GameState.is_dragging:
		if GameState.drag_end_char_slot == self:
			GameState.drag_end_char_slot = null
