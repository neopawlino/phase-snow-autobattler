extends Control

class_name Draggable

var mouseover : bool:
	set(val):
		var changed := mouseover != val
		mouseover = val
		if changed:
			mouseover_changed.emit(val)
signal mouseover_changed(is_mouseover: bool)

var draggable : bool = false:
	set(val):
		draggable = val
		container.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if val else Control.CURSOR_ARROW

var cur_slot : Slot

@export var drag_object : Node
@export var rect_offset : Vector2
@export var container : Container

var drag_initial_pos : Vector2
var drag_offset : Vector2


signal drag_started
signal drag_ended


func _ready() -> void:
	GameState.is_dragging_changed.connect(set_container_mouse_filter)
	# Setting the position in the scene seems to reset when instantiating.
	# Setting it in code here seems to fix that
	container.position = rect_offset


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not GameState.is_dragging and cur_slot:
		global_position = cur_slot.global_position
	if not draggable:
		return
	var rect := container.get_global_rect()
	var mouse_pos := self.get_global_mouse_position()
	if !rect.has_point(mouse_pos) and !GameState.is_dragging:
		mouseover = false
	elif !GameState.is_dragging:
		mouseover = true
	if mouseover and draggable:
		if Input.is_action_just_pressed("click") and not GameState.is_dragging:
			drag_initial_pos = global_position
			drag_offset = get_global_mouse_position() - global_position
			GameState.is_dragging = true
			GameState.drag_object = self.drag_object
			GameState.drag_original_slot = self.cur_slot
			GameState.drag_end_slot = self.cur_slot
			GameState.drag_initial_mouse_pos = get_global_mouse_position()
			self.drag_started.emit()
		if Input.is_action_pressed("click") and GameState.drag_object == self.drag_object:
			global_position = get_global_mouse_position() - drag_offset
		elif Input.is_action_just_released("click") and GameState.drag_object == self.drag_object:
			GameState.is_dragging = false
			GameState.drag_object = null
			self.drag_ended.emit()


func set_container_mouse_filter(is_dragging: bool):
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE if is_dragging else Control.MOUSE_FILTER_PASS
