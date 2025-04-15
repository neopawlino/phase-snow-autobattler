extends Control

class_name Slot

enum SlotType {
	CHARACTER,
	ITEM,
	ABILITY
}

@export var slot_type : SlotType
var slot_index : int
var slot_obj : Node

@export var merge_swap_timer : Timer
@export var show_slot_indicator : bool = true
@export var slot_indicator : Control

@export var anim_sfx : AudioStream

var mouseover : bool:
	set(val):
		var changed := mouseover != val
		mouseover = val
		if changed:
			mouseover_changed.emit(val)
signal mouseover_changed(is_mouseover: bool)

@export var pickable : bool


func _ready() -> void:
	if self.merge_swap_timer:
		self.merge_swap_timer.timeout.connect(drag_swap)
	self.mouseover_changed.connect(func(is_mouseover : bool):
		if is_mouseover:
			on_mouse_entered()
		else:
			on_mouse_exited()
	)
	self.mouse_entered.connect(func():
		self.mouseover = true
	)
	self.mouse_exited.connect(func():
		self.mouseover = false
	)

	GameState.drag_object_changed.connect(update_slot_indicator)
	update_slot_indicator(GameState.drag_object)


func update_slot_indicator(drag_obj : Node):
	if not slot_indicator:
		return
	if not drag_obj or not show_slot_indicator:
		slot_indicator.hide()
		return
	# change visibility of the indicator
	if drag_obj is Ability and self.slot_type == SlotType.ABILITY:
		slot_indicator.show()
	elif drag_obj is Character and self.slot_type == SlotType.CHARACTER:
		slot_indicator.show()


func set_pickable(pickable : bool):
	self.mouse_filter = Control.MOUSE_FILTER_PASS if pickable else Control.MOUSE_FILTER_IGNORE
	self.pickable = pickable


func drag_swap():
	var slots : SlotContainer = self.get_slot_container()
	if GameState.is_dragging and GameState.drag_end_slot == self and slots == GameState.drag_original_slot.get_slot_container():
		slots.reorder_char(GameState.drag_object, slot_index)


func get_slot_container():
	return self.get_meta(&"slot_container")


func on_mouse_entered() -> void:
	print('mouse entered')
	if not GameState.is_dragging or not self.pickable:
		return
	if GameState.drag_object is Character and self.slot_type == SlotType.CHARACTER:
		GameState.drag_end_slot = self
		if GameState.drag_can_swap and self.slot_obj != null and self.slot_obj != GameState.drag_object:
			if self.slot_obj.can_merge(GameState.drag_object):
				merge_swap_timer.start()
			else:
				drag_swap()
	elif GameState.drag_object is Item and self.slot_type == SlotType.ITEM:
		GameState.drag_end_slot = self
		if GameState.drag_can_swap and self.slot_obj != null and GameState.drag_object.cur_slot:
			drag_item_swap()
	elif GameState.drag_object is Ability and self.slot_type == SlotType.ABILITY:
		GameState.drag_end_slot = self


func drag_item_swap():
	if GameState.is_dragging and GameState.drag_end_slot == self:
		GameState.items.reorder_item(GameState.drag_object, slot_index)
		GameState.drag_original_slot = self
		GameState.drag_end_slot = null


func is_empty() -> bool:
	return slot_obj == null


func on_mouse_exited() -> void:
	print('mouse exit')
	if not GameState.is_dragging:
		return
	if GameState.drag_end_slot == self:
		GameState.drag_end_slot = null
	if merge_swap_timer:
		merge_swap_timer.stop()


func play_anim() -> void:
	var tween := self.create_tween()
	tween.tween_property(
		self, "scale", Vector2.ONE * 1.5, 0.02
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(
		self, "scale", Vector2.ONE, 0.3
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_delay(0.02)
	SoundManager.play_sound(self.anim_sfx)
