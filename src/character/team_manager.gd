extends Node

class_name TeamManager

@export var enemy_layouts : EnemyLayouts

var character_scene : PackedScene = preload("res://src/character/character.tscn")
var character_slot_scene : PackedScene = preload("res://src/item/character_slot.tscn")


func _ready():
	GameState.wins_needed = enemy_layouts.wins_needed
	GameState.player_hp = enemy_layouts.initial_lives

	call_deferred(&"load_initial_team")


func load_initial_team():
	add_char(RandomUtil.all_character_definitions.pick_random())


func add_char(char_def : CharacterDefinition):
	var char : Character = character_scene.instantiate()
	char.load_from_character_definition(char_def)
	char.team = Character.Team.PLAYER
	self.add_child(char)
	GameState.main_slots.push_char(char)
