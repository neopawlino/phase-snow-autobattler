extends Node

class_name TeamManager

@export var max_slots : int = 6

@export var initial_player_team : Array[CharacterDefinition]
@export var enemy_layouts : EnemyLayouts

@export var test_character : CharacterDefinition

var character_scene : PackedScene = preload("res://src/character/character.tscn")
var character_slot_scene : PackedScene = preload("res://src/item/character_slot.tscn")


func _ready():
	GameState.wins_needed = enemy_layouts.wins_needed
	GameState.player_hp = enemy_layouts.initial_lives

	load_initial_teams()


func load_initial_teams():
	var i : int = 0
	for char_def in initial_player_team:
		var char : Character = character_scene.instantiate()
		var slot : Slot = GameState.main_slots.slots[i]
		char.load_from_character_definition(char_def)
		char.team = Character.Team.PLAYER
		char.drag_component.cur_slot = slot
		char.drag_component.draggable = true

		char.global_position = slot.global_position
		slot.slot_obj = char
		slot.add_child(char)
		i += 1
