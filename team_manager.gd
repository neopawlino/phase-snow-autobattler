extends Node

class_name TeamManager

@export var initial_player_team : Array[CharacterDefinition]
@export var initial_enemy_team : Array[CharacterDefinition]

@export var test_character : CharacterDefinition

@export var character_scene : PackedScene

var player_team : Array[Character]
var enemy_team : Array[Character]

@export var player_team_container : BoxContainer
@export var enemy_team_container : BoxContainer


func _ready():
	load_initial_teams()


func load_initial_teams():
	for char_def in initial_player_team:
		var char : Character = character_scene.instantiate()
		char.load_from_character_definition(char_def)
		char.team = Character.Team.PLAYER
		char.pos = len(player_team)
		player_team.append(char)
		player_team_container.add_child(char)
	for char_def in initial_enemy_team:
		var char : Character = character_scene.instantiate()
		char.load_from_character_definition(char_def)
		char.team = Character.Team.ENEMY
		char.sprite.scale.x = -0.5
		char.pos = len(enemy_team)
		enemy_team.append(char)
		enemy_team_container.add_child(char)


func add_test_character():
	var char : Character = character_scene.instantiate()
	char.load_from_character_definition(test_character)
	char.team = Character.Team.PLAYER
	char.pos = len(player_team)
	player_team.append(char)
	player_team_container.add_child(char)


func hide_teams():
	player_team_container.visible = false
	enemy_team_container.visible = false
	

func show_teams():
	player_team_container.visible = true
	enemy_team_container.visible = true
