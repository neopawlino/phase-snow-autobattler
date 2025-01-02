extends Node

class_name TeamManager

@export var max_char_slots : int = 6

@export var initial_player_team : Array[CharacterDefinition]
@export var initial_enemy_team : Array[CharacterDefinition]

@export var test_character : CharacterDefinition

var character_scene : PackedScene = preload("res://character.tscn")
var character_slot_scene : PackedScene = preload("res://character_slot.tscn")

# just used for visibility, not positioning
@export var character_container : Control

@export var slots : CharacterSlots


func _ready():
	# load after slots are set up
	call_deferred(&"load_initial_teams")


func load_initial_teams():
	var i : int = 0
	for char_def in initial_player_team:
		var char : Character = character_scene.instantiate()
		var slot := slots.player_team[i]
		char.load_from_character_definition(char_def)
		char.team = Character.Team.PLAYER
		char.pos = slot.slot_index
		char.cur_character_slot = slot
		char.draggable = true

		char.global_position = slot.global_position
		slot.character = char
		self.character_container.add_child(char)
		i += 1
	i = 0
	for char_def in initial_enemy_team:
		var char : Character = character_scene.instantiate()
		var slot := slots.enemy_team[i]
		char.load_from_character_definition(char_def)
		char.team = Character.Team.ENEMY
		char.sprite.scale.x = char.base_scale * -1
		char.pos = slot.slot_index
		char.cur_character_slot = slot
		char.draggable = false

		char.global_position = slot.global_position
		slot.character = char
		self.character_container.add_child(char)
		i += 1


func add_test_character():
	var char : Character = character_scene.instantiate()
	var slot_i := 0
	var slot : CharacterSlot = null
	for cur_slot in slots.player_team:
		if not cur_slot.character:
			slot = cur_slot
			break
	if not slot:
		return
	char.load_from_character_definition(test_character)
	char.team = Character.Team.PLAYER
	char.pos = slot.slot_index
	char.cur_character_slot = slot
	slot.character = char
	char.draggable = true

	char.global_position = slot.global_position
	self.character_container.add_child(char)


func hide_teams():
	character_container.visible = false


func show_teams():
	character_container.visible = true
