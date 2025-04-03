extends Node

class_name SlotContainer

@export var slots : Array[Slot]
@export var is_main_slots : bool
@export var is_bench : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_main_slots:
		GameState.main_slots = self
	if is_bench:
		GameState.bench_slots = self

	GlobalSignals.stream_anim_started.connect(func():
		set_slots_pickable(false)
	)
	GlobalSignals.stream_end_anim_finished.connect(func():
		set_slots_pickable(true)
	)
	for i in range(len(slots)):
		var slot : Slot = slots[i]
		slot.set_pickable(true)
		slot.slot_index = i
		slot.set_meta(&"slot_container", self)


func set_slots_pickable(pickable: bool):
	for slot in slots:
		slot.set_pickable(pickable)


func reorder_char(char : Character, to : int):
	var from := char.pos
	if from < to:
		for i in range(from + 1, to + 1):
			var cur_char := slots[i].slot_obj
			if cur_char:
				move_to_slot_index(cur_char, i - 1)
		move_to_slot_index(char, to)
	elif from > to:
		for i in range(from - 1, to - 1, -1):
			var cur_char := slots[i].slot_obj
			if cur_char:
				move_to_slot_index(cur_char, i + 1)
		move_to_slot_index(char, to)


func move_to_slot_index(char : Character, i : int):
	assert(i < len(slots))
	var slot := slots[i]
	move_to_slot(char, slot)


func move_to_slot(char : Character, slot : Slot):
	char.pos = slot.slot_index
	char.drag_component.move_to_slot(slot)


func set_char_pos(char : Character, i : int):
	assert(i >= 0)
	assert(i < len(slots))
	char.pos = i
	var slot := slots[i]
	char.global_position = slot.global_position


func push_char(char : Character):
	var empty_slot : Slot = null
	for slot in slots:
		if slot.is_empty():
			empty_slot = slot
			break
	if empty_slot == null:
		# no room! (show text or something)
		return
	move_to_slot(char, empty_slot)


func push_char_front(char : Character):
	insert_char(char, 0)


func insert_char(char : Character, i : int):
	if all_slots_full():
		# no room! (show text or something)
		return
	push_char(char)
	reorder_char(char, i)


func all_slots_full() -> bool:
	for slot in slots:
		if not slot.slot_obj:
			return false
	return true


func is_slot_empty(i : int) -> bool:
	var slot := slots[i]
	return slot.slot_obj == null


func foreach_slot_obj(my_func : Callable):
	for slot in slots:
		if slot.slot_obj != null:
			my_func.call(slot.slot_obj)
