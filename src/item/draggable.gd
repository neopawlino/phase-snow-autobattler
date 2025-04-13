extends Control

class_name Draggable

var tooltip_scene := preload("res://src/ui/custom_tooltip.tscn")

var mouseover : bool:
	set(val):
		var changed := mouseover != val
		mouseover = val
		if changed:
			mouseover_changed.emit(val)
signal mouseover_changed(is_mouseover: bool)

@export var draggable : bool = true:
	set(val):
		draggable = val
		update_cursor_shape()

var cur_slot : Slot

@export var drag_object : Node

var drag_initial_pos : Vector2
var drag_offset : Vector2

var was_draggable : bool

var tween : Tween


signal drag_started
signal drag_ended

signal drag_occupied_slot(slot : Slot)


func _ready() -> void:
	self.was_draggable = self.draggable

	GlobalSignals.stream_anim_started.connect(func():
		self.was_draggable = self.draggable
		self.draggable = false
		if GameState.is_dragging and GameState.drag_object == self.drag_object:
			self.on_drag_release()
	)
	GlobalSignals.stream_end_anim_finished.connect(func():
		self.draggable = self.was_draggable
	)

	self.mouse_entered.connect(func():
		self.mouseover = true
	)
	self.mouse_exited.connect(func():
		self.mouseover = false
	)

	update_cursor_shape()


func update_cursor_shape():
	var cursor := Control.CURSOR_POINTING_HAND if self.draggable else Control.CURSOR_ARROW
	self.mouse_default_cursor_shape = cursor


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var tween_running := tween and tween.is_running()
	if not GameState.is_dragging and cur_slot and not tween_running:
		drag_object.global_position = cur_slot.global_position
	if not draggable or tween_running:
		return
	if GameState.is_dragging:
		mouseover = false
	if mouseover and Input.is_action_just_pressed("click") and not GameState.is_dragging:
		drag_initial_pos = drag_object.global_position
		drag_offset = self.get_global_mouse_position() - self.global_position
		GameState.is_dragging = true
		GameState.drag_object = self.drag_object
		GameState.drag_original_slot = self.cur_slot
		GameState.drag_end_slot = self.cur_slot
		GameState.drag_initial_mouse_pos = self.get_global_mouse_position()
		self.drag_object.reparent(GameState.drag_parent, true)
		self.drag_started.emit()
	if Input.is_action_pressed("click") and GameState.drag_object == self.drag_object:
		drag_object.global_position = self.get_global_mouse_position() - drag_offset
	elif Input.is_action_just_released("click") and GameState.drag_object == self.drag_object:
		on_drag_release()


func on_drag_release():
	GameState.is_dragging = false
	if GameState.drag_end_slot and GameState.drag_end_slot.slot_obj:
		self.drag_occupied_slot.emit(GameState.drag_end_slot)
	elif GameState.drag_end_slot and not GameState.drag_end_slot.slot_obj:
		# moving to an empty slot
		self.move_to_slot(GameState.drag_end_slot)
	elif GameState.drag_original_slot:
		# dragging nowhere in particular, or letting go after swapping
		self.move_to_original_slot()
	if GameState.drag_sell_button:
		self.sell()
	GameState.drag_object = null
	self.drag_ended.emit()


func sell():
	var sell_value : float = 0.0
	if self.drag_object is Character:
		sell_value = self.drag_object.sell_value * GameState.inflation_coeff
		self.drag_object.move_abilities_to_inventory()
	elif self.drag_object is Ability:
		sell_value = self.drag_object.sell_value * GameState.inflation_coeff
	else:
		return
	GameState.player_money += sell_value
	var stat_val := StatValue.new()
	stat_val.stat = StatValue.Stat.MONEY
	stat_val.amount = sell_value
	GlobalSignals.show_main_stat_value.emit(stat_val, get_global_mouse_position())
	if self.cur_slot:
		self.cur_slot.slot_obj = null
	self.drag_object.queue_free()
	GameState.drag_sell_button = false


func move_to_original_slot(use_tween : bool = false):
	self.move_to_slot(GameState.drag_original_slot, use_tween)


func move_to_slot(slot : Slot, use_tween : bool = false):
	if self.cur_slot and self.cur_slot.slot_obj == self.drag_object:
		self.cur_slot.slot_obj = null
	var viewport_pos := slot.get_global_transform().origin
	var result_pos := ScreenSpaceUtil.get_screenspace_position(slot, viewport_pos)

	if GameState.drag_object != self.drag_object:
		var from_pos := ScreenSpaceUtil.get_screenspace_position(self, self.get_global_transform().origin)
		self.drag_object.global_position = from_pos
		self.drag_object.reparent(GameState.drag_parent)
	if not GameState.is_dragging or GameState.drag_object != self.drag_object:
		tween = self.create_tween()
		tween.tween_property(self.drag_object, "global_position", result_pos, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_callback(func():
			self.drag_object.global_position = slot.global_position
			self.drag_object.reparent(slot)
		)
	elif GameState.is_dragging and GameState.drag_object == self.drag_object:
		GameState.drag_original_slot = slot

	slot.slot_obj = self.drag_object
	self.cur_slot = slot


func set_container_mouse_filter(is_dragging: bool):
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE if is_dragging else Control.MOUSE_FILTER_PASS


func _make_custom_tooltip(for_text: String) -> Object:
	var tooltip : CustomTooltip = tooltip_scene.instantiate()
	if drag_object is Ability:
		tooltip.update_from_ability_definition(drag_object.ability_definition)
		tooltip.update_sell_value(drag_object.sell_value * GameState.inflation_coeff)
	elif drag_object is Item:
		tooltip.update_from_item_definition(drag_object.item_definition)
	elif drag_object is Character:
		tooltip.update_from_character_definition(drag_object.char_def)
		tooltip.update_sell_value(drag_object.sell_value * GameState.inflation_coeff)
		if not drag_object.abilities.is_empty():
			tooltip.update_ability_description(drag_object.abilities.front())
	return tooltip
