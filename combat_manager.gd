extends Node

class_name CombatManager

var character_scene : PackedScene = preload("res://character.tscn")

var player_team : Array[Character]
var enemy_team : Array[Character]

@export var character_container : Control

@export var result_screen : ResultScreen

@export var combat_summary : CombatSummary

@export var team_manager : TeamManager
@export var shop_manager : ShopManager
@export var slots : Slots

@export var combat_visual_follow_speed : float = 10

var in_combat : bool = false

@export var win_reward : int = 3
@export var lose_reward : int = 0
@export var draw_reward : int = 0

var reward : int
var income : int
var hp_gain : int

var result : CombatSummary.CombatResult


func _ready():
	GameState.combat_manager = self
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
	GameState.close_character_tooltip()
	slots.set_player_slots_pickable(false)
	clear_teams()
	for slot in slots.player_team:
		if slot.slot_obj != null:
			player_team.append(slot.slot_obj.my_duplicate())
	for slot in slots.enemy_team:
		if slot.slot_obj != null:
			enemy_team.append(slot.slot_obj.my_duplicate())
	team_manager.hide_teams()
	show_teams()
	var i := 0
	for char in player_team:
		char.drag_component.draggable = false
		character_container.add_child(char)
		slots.set_char_pos(char, i)
		char.make_timers()
		i += 1
	i = 0
	for char in enemy_team:
		char.drag_component.draggable = false
		character_container.add_child(char)
		slots.set_char_pos(char, i)
		char.make_timers()
		i += 1
	in_combat = true
	proc_start_combat_items()


func proc_start_combat_items():
	for item in GameState.items.get_items(&"test_item"):
		for char in player_team:
			char.add_status(StatusEffect.StatusId.STRENGTH, 1)


func clear_teams():
	for char in player_team:
		char.queue_free()
	for char in enemy_team:
		char.queue_free()
	player_team.clear()
	enemy_team.clear()


func apply_ability(ability: AbilityLevel, target_team: int, targets: Array[int], caster_statuses: Dictionary):
	var team := enemy_team if target_team == Character.Team.ENEMY else player_team
	for target_index in targets:
		assert(target_index >= 0)
		if target_index >= len(team):
			continue
		var target_char := team[target_index]
		target_char.receive_ability(ability, caster_statuses)
		check_character_dead(target_char)


func check_character_dead(char: Character):
	if char.hp <= 0:
		kill_character(char)


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
		# character died to 2 sources on the same tick
		return
	char.queue_free()


func check_combat_over():
	var player_win := enemy_team.is_empty()
	var enemy_win := player_team.is_empty()
	if not player_win and not enemy_win:
		return
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
		hp_gain = -team_manager.enemy_layouts.damage_on_loss
	for char in player_team:
		char.stop_timers()
	for char in enemy_team:
		char.stop_timers()
	in_combat = false
	income = get_player_income()
	combat_summary.show_combat_summary(result, reward, income, hp_gain)


func get_player_income() -> int:
	var income := 0
	for slot in slots.player_team:
		if slot.slot_obj != null:
			income += slot.slot_obj.get_income()
	return income


func _on_combat_summary_continue_button_pressed() -> void:
	hide_teams()
	combat_summary.hide()

	GameState.player_money += GameState.get_interest()
	GameState.player_money += reward
	GameState.player_money += income
	GameState.player_hp += hp_gain
	if GameState.player_hp <= 0:
		result_screen.result_label.text = "You lose!"
		result_screen.hard_mode_label.visible = false
		result_screen.show()
		return

	if result == CombatSummary.CombatResult.WIN:
		GameState.wins += 1
	GameState.round_number += 1
	if GameState.wins >= GameState.wins_needed:
		result_screen.result_label.text = "You win!"
		result_screen.hard_mode_label.visible = not GameState.hard_mode
		result_screen.show()
		team_manager.clear_enemy_slots()
		team_manager.show_teams()
		return

	slots.set_player_slots_pickable(true)

	team_manager.show_teams()

	if GameState.hard_mode:
		team_manager.load_enemy_team_for_round(GameState.round_number)
	else:
		team_manager.load_enemy_team_for_round(GameState.wins)

	shop_manager.show_shop()
	shop_manager.reroll_characters()
	shop_manager.reset_reroll_price()
