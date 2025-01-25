extends Node

class_name Items

var slot_scene : PackedScene = preload("res://character_slot.tscn")

var player_items : Array[Slot]

@export var max_items : int = 5
@export var item_slots_container : Container
@export var items_container : Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.items = self
	for i in range(max_items):
		var slot : Slot = slot_scene.instantiate()
		slot.set_pickable(true)
		slot.slot_index = i
		slot.slot_type = Slot.SlotType.ITEM
		player_items.append(slot)
		item_slots_container.add_child(slot)


func move_to_slot(item : Item, i : int):
	assert(i < max_items)
	var slot := player_items[i]
	if item.cur_slot and item.cur_slot.slot_obj == item:
		item.cur_slot.slot_obj = null
	slot.slot_obj = item
	item.cur_slot = slot
	item.global_position = slot.global_position


func reorder_item(item : Item, to : int):
	assert(item.cur_slot)
	var from := item.cur_slot.slot_index
	if from < to:
		for i in range(from + 1, to + 1):
			var cur_item := player_items[i].slot_obj
			if cur_item:
				move_to_slot(cur_item, i - 1)
		move_to_slot(item, to)
	elif from > to:
		for i in range(from - 1, to - 1, -1):
			var cur_item := player_items[i].slot_obj
			if cur_item:
				move_to_slot(cur_item, i + 1)
		move_to_slot(item, to)


func get_items(item_name : StringName) -> Array[Item]:
	var items : Array[Item] = []
	for slot in player_items:
		if not slot.slot_obj:
			continue
		var item : Item = slot.slot_obj
		if item.item_definition.name == item_name:
			items.append(item)
	return items


func set_items_draggable(draggable : bool):
	for slot in player_items:
		if not slot.slot_obj:
			continue
		var item : Item = slot.slot_obj
		item.drag_component.draggable = draggable
