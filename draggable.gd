extends Control

class_name Draggable

var tooltip_scene := preload("res://custom_tooltip.tscn")

var mouseover : bool:
	set(val):
		var changed := mouseover != val
		mouseover = val
		if changed:
			mouseover_changed.emit(val)
signal mouseover_changed(is_mouseover: bool)

@export var draggable : bool = false:
	set(val):
		draggable = val
		container.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if val else Control.CURSOR_ARROW

var cur_slot : Slot

@export var drag_object : Node
@export var rect_offset : Vector2
@export var container : Control

var drag_initial_pos : Vector2
var drag_offset : Vector2

var was_draggable : bool


signal drag_started
signal drag_ended


func _ready() -> void:
	self.was_draggable = self.draggable

	GlobalSignals.stream_anim_started.connect(func():
		self.was_draggable = self.draggable
		self.draggable = false
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

	# Setting the position in the scene seems to reset when instantiating.
	# Setting it in code here seems to fix that
	container.position = rect_offset


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.global_position = drag_object.global_position
	if not GameState.is_dragging and cur_slot:
		drag_object.global_position = cur_slot.global_position
	if not draggable:
		return
	if GameState.is_dragging:
		mouseover = false
	if mouseover and Input.is_action_just_pressed("click") and not GameState.is_dragging:
		drag_initial_pos = drag_object.global_position
		drag_offset = get_global_mouse_position() - self.global_position
		GameState.is_dragging = true
		GameState.drag_object = self.drag_object
		GameState.drag_original_slot = self.cur_slot
		GameState.drag_end_slot = self.cur_slot
		GameState.drag_initial_mouse_pos = get_global_mouse_position()
		GameState.drag_original_parent = self.drag_object.get_parent()
		self.drag_object.reparent(GameState.drag_parent, true)
		self.drag_started.emit()
	if Input.is_action_pressed("click") and GameState.drag_object == self.drag_object:
		drag_object.global_position = get_global_mouse_position() - drag_offset
	elif Input.is_action_just_released("click") and GameState.drag_object == self.drag_object:
		on_drag_release()


func on_drag_release():
	GameState.is_dragging = false
	GameState.drag_object = null
	if GameState.drag_original_parent:
		self.drag_object.reparent(GameState.drag_original_parent, true)
	GameState.drag_original_parent = null
	self.drag_ended.emit()


func set_container_mouse_filter(is_dragging: bool):
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE if is_dragging else Control.MOUSE_FILTER_PASS


func _make_custom_tooltip(for_text: String) -> Object:
	var tooltip : CustomTooltip = tooltip_scene.instantiate()
	if drag_object is Ability:
		tooltip.update_from_ability_definition(drag_object.ability_definition)
	elif drag_object is Item:
		tooltip.update_from_item_definition(drag_object.item_definition)
	elif drag_object is Character:
		tooltip.update_from_character_definition(drag_object.char_def)
	return tooltip
