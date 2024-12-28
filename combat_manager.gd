extends Node

class_name CombatManager

@export var character_scene : PackedScene

var player_team : Array[Character]
var enemy_team : Array[Character]

@export var player_team_container : BoxContainer
@export var enemy_team_container : BoxContainer

@export var continue_button : Button

@export var team_manager : TeamManager
@export var shop_manager : ShopManager


var in_combat : bool = false


func _ready():
	GlobalSignals.ability_applied.connect(apply_ability)
	hide_teams()


func _physics_process(_delta):
	if in_combat:
		check_combat_over()


func hide_teams():
	player_team_container.visible = false
	enemy_team_container.visible = false


func show_teams():
	player_team_container.visible = true
	enemy_team_container.visible = true


func start_combat():
	clear_teams()
	for char in team_manager.player_team:
		player_team.append(char.my_duplicate())
	for char in team_manager.enemy_team:
		enemy_team.append(char.my_duplicate())
	team_manager.hide_teams()
	show_teams()
	for char in player_team:
		player_team_container.add_child(char)
		char.make_timers()
	for char in enemy_team:
		enemy_team_container.add_child(char)
		char.make_timers()
	in_combat = true


func clear_teams():
	for char in player_team:
		char.queue_free()
	for char in enemy_team:
		char.queue_free()
	player_team.clear()
	enemy_team.clear()


func apply_ability(ability: Ability, target_team: int, targets: Array[int]):
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


func check_combat_over():
	var player_win := enemy_team.is_empty()
	var enemy_win := player_team.is_empty()
	if not player_win and not enemy_win:
		return
	if player_win and enemy_win:
		print("Draw")
	elif player_win:
		print("Player Wins")
	elif enemy_win:
		print("Enemy Wins")
	for char in player_team:
		char.stop_timers()
	for char in enemy_team:
		char.stop_timers()
	in_combat = false
	continue_button.show()


func _on_button_pressed() -> void:
	hide_teams()
	continue_button.hide()
	team_manager.show_teams()
	shop_manager.show_shop()
