extends Control

class_name Slot

enum SlotType {
	CHARACTER,
	ITEM,
}

var slot_type : SlotType
var slot_index : int
var slot_obj : Node

@export var select_container : Container

@onready var merge_swap_timer : Timer = %MergeSwapTimer


var mouseover : bool:
	set(val):
		var changed := mouseover != val
		mouseover = val
		if changed:
			mouseover_changed.emit(val)
signal mouseover_changed(is_mouseover: bool)

var pickable : bool


func _ready() -> void:
	merge_swap_timer.timeout.connect(drag_swap)
	mouseover_changed.connect(func(is_mouseover : bool):
		if is_mouseover:
			on_mouse_entered()
		else:
			on_mouse_exited()
	)


func _process(delta: float) -> void:
	if not pickable:
		return
	var rect := select_container.get_global_rect()
	var mouse_pos := self.get_global_mouse_position()
	if !rect.has_point(mouse_pos) and GameState.is_dragging:
		mouseover = false
	elif GameState.is_dragging:
		mouseover = true


func set_pickable(pickable : bool):
	select_container.mouse_filter = Control.MOUSE_FILTER_PASS if pickable else Control.MOUSE_FILTER_IGNORE
	self.pickable = pickable


func drag_swap():
	if GameState.is_dragging and GameState.drag_end_slot == self:
		GameState.slots.reorder_char(GameState.drag_object, slot_index)
		GameState.drag_original_slot = self
		GameState.drag_end_slot = null


func on_mouse_entered() -> void:
	if not GameState.is_dragging:
		return
	if GameState.drag_object is Character and self.slot_type == SlotType.CHARACTER:
		GameState.drag_end_slot = self
		if GameState.drag_can_swap and self.slot_obj != null:
			if self.slot_obj.can_merge(GameState.drag_object):
				merge_swap_timer.start()
			else:
				drag_swap()
	elif GameState.drag_object is Item and self.slot_type == SlotType.ITEM:
		GameState.drag_end_slot = self
		# TODO Item slot swapping


func on_mouse_exited() -> void:
	if not GameState.is_dragging:
		return
	if GameState.drag_end_slot == self:
		GameState.drag_end_slot = null
	merge_swap_timer.stop()
