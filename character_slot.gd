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
		if GameState.drag_can_swap and self.character:
			# future: differentiate merge and swap (different hitbox?)
			GameState.slots.reorder_char(GameState.drag_char, slot_index)
			GameState.drag_original_char_slot = self
			GameState.drag_end_char_slot = null


func _on_static_body_2d_mouse_exited() -> void:
	if GameState.is_dragging:
		if GameState.drag_end_char_slot == self:
			GameState.drag_end_char_slot = null
