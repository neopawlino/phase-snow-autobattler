extends Node

class_name CharacterSlots

@export var max_slots : int = 6

var player_team : Array[CharacterSlot]
var enemy_team : Array[CharacterSlot]

@export var player_slot_container : BoxContainer
@export var enemy_slot_container : BoxContainer

@export var character_slot_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(max_slots):
		var slot : CharacterSlot = character_slot_scene.instantiate()
		player_team.append(slot)
		player_slot_container.add_child(slot)

		var enemy_slot : CharacterSlot = character_slot_scene.instantiate()
		enemy_team.append(enemy_slot)
		enemy_slot_container.add_child(enemy_slot)
