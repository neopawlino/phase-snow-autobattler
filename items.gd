extends Node

class_name Items

var slot_scene : PackedScene = preload("res://character_slot.tscn")

# TODO Item class
var player_items : Array[Slot]

@export var max_items : int = 5
@export var player_items_container : Container

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.items = self
	for i in range(max_items):
		var slot : Slot = slot_scene.instantiate()
		slot.set_pickable(true)
		slot.slot_index = i
		slot.slot_type = Slot.SlotType.ITEM
		player_items.append(slot)
		player_items_container.add_child(slot)


func move_to_slot(item : Item, slot_index : int):
	# TODO
	pass
