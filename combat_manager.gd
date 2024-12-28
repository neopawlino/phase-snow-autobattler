extends Node

@export var initial_player_team : Array[CharacterDefinition]
@export var initial_enemy_team : Array[CharacterDefinition]

@export var character_scene : PackedScene

var player_team : Array[Character]
var enemy_team : Array[Character]

@export var player_team_container : BoxContainer
@export var enemy_team_container : BoxContainer


func _ready():
	GlobalSignals.ability_applied.connect(apply_ability)
	load_initial_teams()
	start_combat()


func load_initial_teams():
	for char_def in initial_player_team:
		var char : Character = character_scene.instantiate()
		char.load_from_character_definition(char_def)
		char.team = Character.Team.PLAYER
		player_team.append(char)
		player_team_container.add_child(char)
	for char_def in initial_enemy_team:
		var char : Character = character_scene.instantiate()
		char.load_from_character_definition(char_def)
		char.team = Character.Team.ENEMY
		char.scale.x = -0.5
		enemy_team.append(char)
		enemy_team_container.add_child(char)


func start_combat():
	# TODO transition from shop to combat phase by saving character states
	for char in player_team:
		char.make_timers()
	for char in enemy_team:
		char.make_timers()


func apply_ability(ability: Ability, target_team: int, targets: Array[int]):
	print(targets)
	var team := enemy_team if target_team == Character.Team.ENEMY else player_team
	for target_index in targets:
		if target_index >= len(team):
			continue
		var target_char := team[target_index]
		target_char.receive_ability(ability)
		if target_char.hp <= 0:
			kill_character(target_char)


func kill_character(char: Character):
	var player_index := player_team.find(char)
	var enemy_index := enemy_team.find(char)
	if player_index >= 0:
		player_team.remove_at(player_index)
		print("Player dead")
	elif enemy_index >= 0:
		enemy_team.remove_at(enemy_index)
		print("Enemy dead")
	else:
		push_error("Couldn't find character to kill")
		assert(false)
	char.queue_free()
