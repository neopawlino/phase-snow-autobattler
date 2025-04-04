extends Node

class_name StreamManager

var character_scene : PackedScene = preload("res://character.tscn")

var player_team : Array[Character]
var enemy_team : Array[Character]

var original_player_team : Array[Character]

@export var character_container : Control

@export var result_screen : ResultScreen

@export var combat_visual_follow_speed : float = 10

var in_stream : bool = false

@export var win_reward : int = 3
@export var lose_reward : int = 0
@export var draw_reward : int = 0

var reward : int
var income : int
var hp_gain : int

var result : StreamSummary.StreamResult

var viewer_goal : float:
	set(amt):
		viewer_goal = amt
		viewer_goal_changed.emit(amt)
signal viewer_goal_changed(amt: float)

var viewers : float:
	set(amt):
		if amt > viewers:
			self.on_viewers_gained(amt - viewers)
		viewers = amt
		viewers_changed.emit(amt)
signal viewers_changed(amt: float)

var views : float:
	set(amt):
		if amt > views:
			self.on_views_gained(amt - views)
		views = amt
		views_changed.emit(amt)
signal views_changed(amt: float)

var peak_viewers : float:
	set(amt):
		peak_viewers = amt
		peak_viewers_changed.emit(amt)
signal peak_viewers_changed(amt: float)

var views_per_sec : float:
	set(amt):
		views_per_sec = amt
		views_per_sec_changed.emit(amt)
signal views_per_sec_changed(amt: float)

var viewer_retention : float:
	set(amt):
		viewer_retention = amt
		viewer_retention_changed.emit(amt)
signal viewer_retention_changed(amt: float)

var subscriber_rate : float:
	set(amt):
		subscriber_rate = amt
		subscriber_rate_changed.emit(amt)
signal subscriber_rate_changed(amt: float)

# to calculate change in subscribers
var prev_subscribers : float

var member_rate : float:
	set(amt):
		member_rate = amt
		member_rate_changed.emit(amt)
signal member_rate_changed(amt: float)

# subscribers gained this stream
var new_subscribers : float
# members gained this stream
var new_members : float

var base_revenue : float = 5.0
var ad_revenue : float
var ad_rpm : float = 2.5
var member_revenue : float
var revenue_per_member : float = 1.0

var total_revenue : float

var damage_tick_timer : float

func _ready():
	GameState.stream_manager = self
	GlobalSignals.ability_applied.connect(apply_ability)
	GlobalSignals.character_died.connect(on_character_died)
	GlobalSignals.player_character_died.connect(on_player_character_died)
	GlobalSignals.stream_started.connect(start_stream)
	GlobalSignals.stream_end_anim_finished.connect(show_orig_team)

	GlobalSignals.stream_results_confirmed.connect(reset_stats)
	GameState.subscribers_changed.connect(on_subscribers_changed)
	hide_teams()


func _physics_process(delta : float):
	if not in_stream:
		return
	views += randfn(views_per_sec * delta, (views_per_sec * delta) * 0.5)
	peak_viewers = maxf(viewers, peak_viewers)

	damage_tick_timer += delta
	if damage_tick_timer >= 1.0:
		damage_all_characters(1)
		damage_tick_timer -= 1.0
	check_stream_over()


static func calc_amt_gained(amt_gained : float, prob : float) -> float:
	return roundf(RandomUtil.binomial(floorf(amt_gained), prob)) \
		+ RandomUtil.bernoulli(prob * fmod(amt_gained, 1.0))


func on_views_gained(amt_gained : float):
	self.viewers += calc_amt_gained(amt_gained, viewer_retention)


func on_viewers_gained(amt_gained : float):
	var subscribers_gained := calc_amt_gained(amt_gained, subscriber_rate)
	GameState.subscribers += subscribers_gained
	self.new_subscribers += subscribers_gained


func on_subscribers_changed(new_amt : float):
	var change := new_amt - prev_subscribers
	if change > 0:
		on_subscribers_gained(change)
	self.prev_subscribers = new_amt


func on_subscribers_gained(amt_gained : float):
	if not self.in_stream:
		return
	var members_gained := calc_amt_gained(amt_gained, member_rate)
	GameState.members += members_gained
	self.new_members += members_gained


func damage_all_characters(hp : int):
	var current_team := player_team.duplicate()
	for char in current_team:
		char.take_damage(hp)

	current_team = enemy_team.duplicate()
	for char in current_team:
		char.take_damage(hp)


func hide_teams():
	character_container.visible = false


func show_teams():
	character_container.visible = true


func hide_orig_team():
	for char in original_player_team:
		char.hide()


func show_orig_team():
	for char in original_player_team:
		char.show()


func reset_stats():
	viewers = 0
	views_per_sec = GameState.base_views_per_sec
	subscriber_rate = GameState.base_subscriber_rate
	member_rate = GameState.base_member_rate
	viewer_retention = GameState.base_viewer_retention
	prev_subscribers = GameState.subscribers
	new_subscribers = 0
	new_members = 0
	views = 0

	ad_revenue = 0
	member_revenue = 0


func start_stream():
	reset_stats()
	viewer_goal = GameState.viewer_goal

	clear_teams()
	original_player_team.clear()
	for slot in GameState.main_slots.slots:
		if slot.slot_obj is Character:
			original_player_team.append(slot.slot_obj)
			player_team.append(slot.slot_obj.my_duplicate())
	hide_orig_team()
	show_teams()
	var i := 0
	for char in player_team:
		char.drag_component.draggable = false
		character_container.add_child(char)
		GameState.main_slots.set_char_visual_pos(char, i)
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
		var empty_slots := len(GameState.main_slots.slots) - len(player_team)
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


func apply_ability(ability: AbilityDefinition, caster_statuses: Dictionary, caster: Character):
	#var team := self.enemy_team if target_team == Character.Team.ENEMY else self.player_team
	#for target_index in targets:
		#assert(target_index >= 0)
		#if target_index >= len(team):
			#continue
		#var target_char := team[target_index]
		#target_char.receive_ability(ability, caster_statuses)
	var amount_add := calc_stat_scaling_amount(ability, caster)
	for stat_change in ability.stat_changes:
		match stat_change.stat:
			StatValue.Stat.VIEWS:
				self.views += stat_change.amount + amount_add
			StatValue.Stat.VIEWS_PER_SEC:
				self.views_per_sec += stat_change.amount + amount_add
			StatValue.Stat.VIEWER_RETENTION:
				self.viewer_retention += stat_change.amount + amount_add
			StatValue.Stat.VIEWERS:
				self.viewers += stat_change.amount + amount_add
			StatValue.Stat.SUBSCRIBER_RATE:
				self.subscriber_rate += stat_change.amount + amount_add
			StatValue.Stat.SUBSCRIBERS:
				GameState.subscribers += stat_change.amount + amount_add
			StatValue.Stat.MEMBER_RATE:
				self.member_rate += stat_change.amount + amount_add
			StatValue.Stat.MEMBERS:
				GameState.members += stat_change.amount + amount_add
			StatValue.Stat.STAMINA:
				caster.hp += stat_change.amount + amount_add
			_:
				print_debug("Couldn't match stat: %s" % stat_change.stat)


func calc_stat_scaling_amount(ability: AbilityDefinition, caster: Character) -> float:
	var amt : float = 0
	for stat_val in ability.scaling:
		match stat_val.stat:
			StatValue.Stat.VIEWS:
				amt += self.views * stat_val.amount
			StatValue.Stat.VIEWS_PER_SEC:
				amt += self.views_per_sec * stat_val.amount
			StatValue.Stat.VIEWER_RETENTION:
				amt += self.viewer_retention * stat_val.amount
			StatValue.Stat.VIEWERS:
				amt += self.viewers * stat_val.amount
			StatValue.Stat.SUBSCRIBER_RATE:
				amt += self.subscriber_rate * stat_val.amount
			StatValue.Stat.SUBSCRIBERS:
				amt += GameState.subscribers * stat_val.amount
			StatValue.Stat.MEMBER_RATE:
				amt += self.member_rate * stat_val.amount
			StatValue.Stat.MEMBERS:
				amt += GameState.members * stat_val.amount
			StatValue.Stat.STAMINA:
				amt += caster.hp * stat_val.amount
	return amt


func kill_character(char : Character):
	var player_index := player_team.find(char)
	var enemy_index := enemy_team.find(char)
	if player_index >= 0:
		player_team.remove_at(player_index)
		if char.drag_component.cur_slot:
			char.drag_component.cur_slot.slot_obj = null
		if player_index == 0:
			apply_front_character_items()
		GlobalSignals.player_character_died.emit(char)
	elif enemy_index >= 0:
		enemy_team.remove_at(enemy_index)
		if char.drag_component.cur_slot:
			char.drag_component.cur_slot.slot_obj = null
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
		char.cur_slot.get_slot_container().set_char_visual_pos(char, i)
	for i in len(enemy_team):
		var char := enemy_team[i]
		char.cur_slot.get_slot_container().set_char_visual_pos(char, i)


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
		result = StreamSummary.StreamResult.WIN
	else:
		result = StreamSummary.StreamResult.LOSE
	for char in player_team:
		char.stop_timers()
	for char in enemy_team:
		char.stop_timers()
	in_stream = false
	self.update_revenue()
	GlobalSignals.stream_ended.emit(result, 0, income, 0)


func update_revenue() -> void:
	self.ad_revenue = self.views * self.ad_rpm / 1000.0
	self.member_revenue = self.revenue_per_member * GameState.members
	self.total_revenue = self.get_total_revenue()


func get_total_revenue() -> float:
	return self.base_revenue + self.ad_revenue + self.member_revenue


func proc_end_combat_items():
	for item in GameState.items.get_items(&"hp_gain"):
		GameState.main_slots.foreach_slot_obj(func(char: Character):
			char.add_max_hp(2)
		)
