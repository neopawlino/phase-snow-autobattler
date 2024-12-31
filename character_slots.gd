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


func reorder_char(char : Character, to : int):
	var slots := player_team if char.team == Character.Team.PLAYER else enemy_team
	var from := char.pos
	if from < to:
		for i in range(from + 1, to + 1):
			var cur_char := slots[i].character
			if cur_char:
				move_to_slot(cur_char, i - 1)
		move_to_slot(char, to)
	elif from > to:
		for i in range(from - 1, to - 1, -1):
			var cur_char := slots[i].character
			if cur_char:
				move_to_slot(cur_char, i + 1)
		move_to_slot(char, to)


func move_to_slot(char : Character, i : int):
	assert(i < max_slots)
	char.pos = i
	var slot := player_team[i] if char.team == Character.Team.PLAYER else enemy_team[i]
	if char.cur_character_slot and char.cur_character_slot.character == char:
		char.cur_character_slot.character = null
	slot.character = char
	char.cur_character_slot = slot
	char.global_position = slot.global_position


func set_char_pos(char : Character, i : int):
	assert(i < max_slots)
	char.pos = i
	var slot := player_team[i] if char.team == Character.Team.PLAYER else enemy_team[i]
	char.global_position = slot.global_position


func all_slots_full(team : Character.Team = Character.Team.PLAYER) -> bool:
	var slots := player_team if team == Character.Team.PLAYER else enemy_team
	for slot in slots:
		if not slot.character:
			return false
	return true


func is_slot_empty(team : Character.Team, i : int) -> bool:
	var slot := player_team[i] if team == Character.Team.PLAYER else enemy_team[i]
	return slot.character == null
