extends Node

class_name CombatManager

var character_scene : PackedScene = preload("res://character.tscn")

var player_team : Array[Character]
var enemy_team : Array[Character]

@export var character_container : Control

@export var lose_screen : Control

@export var combat_summary : CombatSummary

@export var team_manager : TeamManager
@export var shop_manager : ShopManager
@export var slots : CharacterSlots

@export var combat_visual_follow_speed : float = 10

var in_combat : bool = false

@export var win_reward : int = 3
@export var lose_reward : int = 0
@export var draw_reward : int = 0

@export var lose_hp_damage : int = 2

var reward : int
var hp_gain : int

func _ready():
	GlobalSignals.ability_applied.connect(apply_ability)
	hide_teams()


func _physics_process(_delta):
	if in_combat:
		check_combat_over()


func hide_teams():
	character_container.visible = false


func show_teams():
	character_container.visible = true


func start_combat():
	clear_teams()
	for slot in slots.player_team:
		if slot.character != null:
			player_team.append(slot.character.my_duplicate())
	for slot in slots.enemy_team:
		if slot.character != null:
			enemy_team.append(slot.character.my_duplicate())
	team_manager.hide_teams()
	show_teams()
	var i := 0
	for char in player_team:
		char.visual_follow_speed = combat_visual_follow_speed
		char.draggable = false
		character_container.add_child(char)
		slots.set_char_pos(char, i)
		char.make_timers()
		i += 1
	i = 0
	for char in enemy_team:
		char.visual_follow_speed = combat_visual_follow_speed
		char.draggable = false
		character_container.add_child(char)
		slots.set_char_pos(char, i)
		char.make_timers()
		i += 1
	in_combat = true


func clear_teams():
	for char in player_team:
		char.queue_free()
	for char in enemy_team:
		char.queue_free()
	player_team.clear()
	enemy_team.clear()


func apply_ability(ability: AbilityLevel, target_team: int, targets: Array[int]):
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
		for i in range(player_index, len(player_team)):
			var char_to_move := player_team[i]
			var new_pos := char_to_move.pos - 1
			slots.set_char_pos(char_to_move, new_pos)
	elif enemy_index >= 0:
		enemy_team.remove_at(enemy_index)
		for i in range(enemy_index, len(enemy_team)):
			var char_to_move := enemy_team[i]
			var new_pos := char_to_move.pos - 1
			slots.set_char_pos(char_to_move, new_pos)
	else:
		push_error("Couldn't find character to kill")
		assert(false)
	char.queue_free()


func check_combat_over():
	var player_win := enemy_team.is_empty()
	var enemy_win := player_team.is_empty()
	if not player_win and not enemy_win:
		return
	var result : CombatSummary.CombatResult
	if player_win and enemy_win:
		result = CombatSummary.CombatResult.DRAW
		reward = draw_reward
		hp_gain = 0
	elif player_win:
		result = CombatSummary.CombatResult.WIN
		reward = win_reward
		hp_gain = 0
	elif enemy_win:
		result = CombatSummary.CombatResult.LOSE
		reward = lose_reward
		hp_gain = -lose_hp_damage
	for char in player_team:
		char.stop_timers()
	for char in enemy_team:
		char.stop_timers()
	in_combat = false
	combat_summary.show_combat_summary(result, reward, hp_gain)


func _on_combat_summary_continue_button_pressed() -> void:
	hide_teams()
	combat_summary.hide()

	GameState.player_money += GameState.get_interest()
	GameState.player_money += reward
	GameState.player_hp += hp_gain
	if GameState.player_hp <= 0:
		lose_screen.show()
		return

	team_manager.show_teams()
	shop_manager.show_shop()
	shop_manager.reroll_characters()
	shop_manager.reset_reroll_price()
