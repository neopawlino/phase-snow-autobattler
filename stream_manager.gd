extends Node

class_name CombatManager

var character_scene : PackedScene = preload("res://character.tscn")

var player_team : Array[Character]
var enemy_team : Array[Character]

@export var character_container : Control

@export var result_screen : ResultScreen

@export var slots : Slots

@export var combat_visual_follow_speed : float = 10

var in_stream : bool = false

@export var win_reward : int = 3
@export var lose_reward : int = 0
@export var draw_reward : int = 0

var reward : int
var income : int
var hp_gain : int

var result : CombatSummary.CombatResult

var viewer_goal : float

var viewers : float
var peak_viewers : float
var views_per_sec : float

var damage_tick_timer : float


func _ready():
	GameState.combat_manager = self
	GlobalSignals.ability_applied.connect(apply_ability)
	GlobalSignals.character_died.connect(on_character_died)
	GlobalSignals.player_character_died.connect(on_player_character_died)
	GlobalSignals.stream_started.connect(start_stream)
	hide_teams()


func _physics_process(delta : float):
	if not in_stream:
		return
	viewers += views_per_sec * delta
	peak_viewers = maxf(viewers, peak_viewers)
	damage_tick_timer += delta
	if damage_tick_timer >= 1.0:
		damage_all_characters(10)
		damage_tick_timer -= 1.0
	check_stream_over()


func damage_all_characters(hp : int):
	for char in player_team:
		char.take_damage(hp)
	for char in enemy_team:
		char.take_damage(hp)


func hide_teams():
	character_container.visible = false


func show_teams():
	character_container.visible = true


func start_stream():
	viewers = 0
	views_per_sec = 0

	clear_teams()
	#GameState.items.set_items_draggable(false)
	for slot in slots.player_team:
		if slot.slot_obj != null:
			player_team.append(slot.slot_obj.my_duplicate())
	#for slot in slots.enemy_team:
		#if slot.slot_obj != null:
			#enemy_team.append(slot.slot_obj.my_duplicate())
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
	in_stream = true
	proc_start_stream_items()
	apply_front_character_items()


func proc_start_stream_items():
	if not GameState.items:
		return
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
	if not GameState.items or player_team.is_empty():
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
	# for testing
	viewers += 10


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
	if GameState.items:
		for item in GameState.items.get_items(&"buff_on_death"):
			for team_char in player_team:
				team_char.add_status(StatusEffect.StatusId.STRENGTH, 1)
				team_char.add_status(StatusEffect.StatusId.ARMOR, 1)


func check_stream_over():
	if not player_team.is_empty():
		return
	if self.peak_viewers >= GameState.viewer_goal:
		result = CombatSummary.CombatResult.WIN
	else:
		result = CombatSummary.CombatResult.LOSE
	for char in player_team:
		char.stop_timers()
	for char in enemy_team:
		char.stop_timers()
	in_stream = false
	income = get_player_income()
	GlobalSignals.stream_ended.emit(result, 0, income, 0)


func get_player_income() -> int:
	var income := 0
	for slot in slots.player_team:
		if slot.slot_obj != null:
			income += slot.slot_obj.get_income()
	income += get_item_income()
	return income


func get_item_income() -> int:
	if not GameState.items:
		return 0
	var income := 0
	for item in GameState.items.get_items(&"income_up"):
		income += 4
	return income


func _on_combat_summary_continue_button_pressed() -> void:
	hide_teams()

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
		return

	GameState.items.set_items_draggable(true)

	proc_end_combat_items()


func proc_end_combat_items():
	for item in GameState.items.get_items(&"hp_gain"):
		slots.foreach_player_team(func(char: Character):
			char.add_max_hp(2)
		)
