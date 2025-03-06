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
	GlobalSignals.character_died.connect(on_character_died)
	GlobalSignals.player_character_died.connect(on_player_character_died)
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
	GameState.items.set_items_draggable(false)
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
		char.died.connect(kill_character.bind(char))
		i += 1
	i = 0
	for char in enemy_team:
		char.drag_component.draggable = false
		character_container.add_child(char)
		slots.set_char_pos(char, i)
		char.make_timers()
		char.died.connect(kill_character.bind(char))
		i += 1
	in_combat = true
	proc_start_combat_items()
	apply_front_character_items()


func proc_start_combat_items():
	for item in GameState.items.get_items(&"str_item"):
		for char in player_team:
			char.add_status(StatusEffect.StatusId.STRENGTH, 1)
	for item in GameState.items.get_items(&"empty_slot_buff"):
		var empty_slots := slots.max_slots - len(player_team)
		for char in player_team:
			char.add_status(StatusEffect.StatusId.STRENGTH, empty_slots)
			char.add_status(StatusEffect.StatusId.ARMOR, empty_slots)
	for item in GameState.items.get_items(&"toxic_up"):
		for char in player_team:
			char.add_status(StatusEffect.StatusId.ENVENOM, 1)
	for item in GameState.items.get_items(&"toxic_only"):
		for char in player_team:
			char.add_status(StatusEffect.StatusId.ENVENOM, 5)
			char.add_status(StatusEffect.StatusId.STRENGTH, -99)


func apply_front_character_items():
	if player_team.is_empty():
		return
	var char := player_team[0]
	char.hp_changed.connect(func(new_hp: int, old_hp: int):
		if new_hp < old_hp:
			for item in GameState.items.get_items(&"str_on_damage"):
				char.add_status(StatusEffect.StatusId.STRENGTH, 1)
	)


func clear_teams():
	for char in player_team:
		char.queue_free()
	for char in enemy_team:
		char.queue_free()
	player_team.clear()
	enemy_team.clear()


func apply_ability(ability: AbilityLevel, target_team: int, targets: Array[int], caster_statuses: Dictionary):
	var team := self.enemy_team if target_team == Character.Team.ENEMY else self.player_team
	for target_index in targets:
		assert(target_index >= 0)
		if target_index >= len(team):
			continue
		var target_char := team[target_index]
		target_char.receive_ability(ability, caster_statuses)


func kill_character(char : Character):
	var player_index := player_team.find(char)
	var enemy_index := enemy_team.find(char)
	if player_index >= 0:
		player_team.remove_at(player_index)
		if char.cur_character_slot:
			char.cur_character_slot.slot_obj = null
		for i in range(char.pos, len(player_team)):
			var char_to_move := player_team[i]
			var new_pos := char_to_move.pos - 1
			slots.set_char_pos(char_to_move, new_pos)
		if player_index == 0:
			apply_front_character_items()
		GlobalSignals.player_character_died.emit(char)
	elif enemy_index >= 0:
		enemy_team.remove_at(enemy_index)
		if char.cur_character_slot:
			char.cur_character_slot.slot_obj = null
		for i in range(char.pos, len(enemy_team)):
			var char_to_move := enemy_team[i]
			var new_pos := char_to_move.pos - 1
			slots.set_char_pos(char_to_move, new_pos)
	else:
		# character died to 2 sources on the same tick
		return
	GlobalSignals.character_died.emit(char)


func summon_character(char_def : CharacterDefinition, team : Character.Team, pos : int = 0):
	var char : Character = Character.spawn_from_character_definition(char_def)
	char.team = team
	char.set_flipped(team == Character.Team.ENEMY)
	character_container.add_child(char)
	if team == Character.Team.PLAYER:
		player_team.insert(pos, char)
	else:
		enemy_team.insert(pos, char)
	update_positions()
	char.make_timers()
	char.died.connect(kill_character.bind(char))


func update_positions():
	for i in len(player_team):
		var char := player_team[i]
		slots.set_char_pos(char, i)
	for i in len(enemy_team):
		var char := enemy_team[i]
		slots.set_char_pos(char, i)


func on_character_died(char : Character):
	for st in char.get_unique_statuses(&"SummonOnDeath"):
		var summon_st : SummonOnDeath = st
		for summon in summon_st.summons:
			summon_character(summon, char.team, char.pos)


func on_player_character_died(char : Character):
	for item in GameState.items.get_items(&"buff_on_death"):
		for team_char in player_team:
			team_char.add_status(StatusEffect.StatusId.STRENGTH, 1)
			team_char.add_status(StatusEffect.StatusId.ARMOR, 1)


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
	income += get_item_income()
	return income


func get_item_income() -> int:
	var income := 0
	for item in GameState.items.get_items(&"income_up"):
		income += 4
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
	GameState.items.set_items_draggable(true)

	team_manager.show_teams()

	if GameState.hard_mode:
		team_manager.load_enemy_team_for_round(GameState.round_number)
	else:
		team_manager.load_enemy_team_for_round(GameState.wins)

	shop_manager.show_shop()
	shop_manager.reroll_all()
	shop_manager.reset_reroll_price()

	proc_end_combat_items()


func proc_end_combat_items():
	for item in GameState.items.get_items(&"hp_gain"):
		slots.foreach_player_team(func(char: Character):
			char.add_max_hp(2)
		)
