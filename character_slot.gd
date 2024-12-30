extends Control

class_name CharacterSlot


func _on_static_body_2d_mouse_entered() -> void:
	if GameState.is_dragging:
		GameState.drag_end_char_slot = self
		if GameState.drag_can_swap:
			# TODO logic for swapping characters (call a function on GameState.team_manager)
			pass


func _on_static_body_2d_mouse_exited() -> void:
	if GameState.is_dragging:
		GameState.drag_end_char_slot = null
