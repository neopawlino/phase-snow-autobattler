extends Node

class_name Slots

@export var max_slots : int = 6

var player_team : Array[Slot]
var enemy_team : Array[Slot]

@export var player_slot_container : BoxContainer
@export var enemy_slot_container : BoxContainer

var character_slot_scene : PackedScene = preload("res://character_slot.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.slots = self
	for i in range(max_slots):
		var slot : Slot = character_slot_scene.instantiate()
		slot.set_pickable(true)
		slot.slot_index = i
		slot.slot_type = Slot.SlotType.CHARACTER
		player_team.append(slot)
		player_slot_container.add_child(slot)

		var enemy_slot : Slot = character_slot_scene.instantiate()
		enemy_slot.set_pickable(false)
		enemy_slot.slot_index = i
		enemy_slot.slot_type = Slot.SlotType.CHARACTER
		enemy_team.append(enemy_slot)
		enemy_slot_container.add_child(enemy_slot)


func set_player_slots_pickable(pickable: bool):
	for slot in player_team:
		slot.set_pickable(pickable)


func reorder_char(char : Character, to : int):
	var slots := player_team if char.team == Character.Team.PLAYER else enemy_team
	var from := char.pos
	if from < to:
		for i in range(from + 1, to + 1):
			var cur_char := slots[i].slot_obj
			if cur_char:
				move_to_slot(cur_char, i - 1)
		move_to_slot(char, to)
	elif from > to:
		for i in range(from - 1, to - 1, -1):
			var cur_char := slots[i].slot_obj
			if cur_char:
				move_to_slot(cur_char, i + 1)
		move_to_slot(char, to)


func move_to_slot(char : Character, i : int):
	assert(i < max_slots)
	char.pos = i
	var slot := player_team[i] if char.team == Character.Team.PLAYER else enemy_team[i]
	if char.cur_character_slot and char.cur_character_slot.slot_obj == char:
		char.cur_character_slot.slot_obj = null
	slot.slot_obj = char
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
		if not slot.slot_obj:
			return false
	return true


func is_slot_empty(team : Character.Team, i : int) -> bool:
	var slot := player_team[i] if team == Character.Team.PLAYER else enemy_team[i]
	return slot.slot_obj == null


func foreach_player_team(my_func : Callable):
	for slot in player_team:
		if slot.slot_obj != null:
			my_func.call(slot.slot_obj)
