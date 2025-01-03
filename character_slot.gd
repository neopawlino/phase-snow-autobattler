extends Control

class_name CharacterSlot

var slot_index : int
var character : Character

@export var body : StaticBody2D

@onready var merge_swap_timer : Timer = %MergeSwapTimer


func _ready() -> void:
	merge_swap_timer.timeout.connect(drag_swap)


func set_pickable(pickable : bool):
	body.input_pickable = pickable


func _on_static_body_2d_mouse_entered() -> void:
	if GameState.is_dragging:
		GameState.drag_end_char_slot = self
		if GameState.drag_can_swap and self.character != null:
			if self.character.can_merge(GameState.drag_char):
				merge_swap_timer.start()
			else:
				drag_swap()


func drag_swap():
	if GameState.is_dragging and GameState.drag_end_char_slot == self:
		GameState.slots.reorder_char(GameState.drag_char, slot_index)
		GameState.drag_original_char_slot = self
		GameState.drag_end_char_slot = null


func _on_static_body_2d_mouse_exited() -> void:
	if GameState.is_dragging:
		if GameState.drag_end_char_slot == self:
			GameState.drag_end_char_slot = null
		merge_swap_timer.stop()
