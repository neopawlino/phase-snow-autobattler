extends Control

class_name Ability

@export var drag_component : Draggable

func _ready() -> void:
	drag_component.drag_ended.connect(on_drag_ended)


func on_drag_ended():
	if GameState.drag_end_slot and GameState.drag_end_slot.slot_obj:
		# TODO swap
		pass
	elif GameState.drag_end_slot and not GameState.drag_end_slot.slot_obj:
		# dragging to an empty slot
		self.global_position = GameState.drag_end_slot.global_position
		self.reparent(GameState.drag_end_slot)
	elif GameState.drag_original_slot:
		# dragging nowhere in particular, or letting go after swapping
		self.global_position = GameState.drag_original_slot.global_position
		GameState.drag_original_slot = null
