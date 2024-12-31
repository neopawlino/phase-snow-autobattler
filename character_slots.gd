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
	GameState.slots = self
	for i in range(max_slots):
		var slot : CharacterSlot = character_slot_scene.instantiate()
		slot.set_pickable(true)
		slot.slot_index = i
		player_team.append(slot)
		player_slot_container.add_child(slot)

		var enemy_slot : CharacterSlot = character_slot_scene.instantiate()
		enemy_slot.set_pickable(false)
		enemy_slot.slot_index = i
		enemy_team.append(enemy_slot)
		enemy_slot_container.add_child(enemy_slot)


func set_char_pos(char : Character, i : int):
	assert(i < max_slots)
	char.pos = i
	var slot := player_team[i] if char.team == Character.Team.PLAYER else enemy_team[i]
	char.global_position = slot.global_position


func is_slot_empty(team : Character.Team, i : int) -> bool:
	var slot := player_team[i] if team == Character.Team.PLAYER else enemy_team[i]
	return slot.character == null
