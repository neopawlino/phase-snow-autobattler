extends Node

class_name StreamManager

var character_scene : PackedScene = preload("res://src/character/character.tscn")

var player_team : Array[Character]
var enemy_team : Array[Character]

var original_player_team : Array[Character]

@export var character_container : Control

@export var combat_visual_follow_speed : float = 10

var in_stream : bool = false

@export var tick_sound : AudioStream
@export var tick_start_pitch : float = 0.5
@export var tick_end_pitch : float = 1.5
@export var tick_volume : float = -6.0
@export var tick_debounce_time : float = 0.1
var tick_sound_timer : Timer
var can_tick : bool

@export var hp_drain_increase_start_delay : float = 25.0
@export var hp_drain_increase_interval : float = 5.0
var hp_drain : int
var hp_drain_increase_timer : float
var hp_drain_increase_started : bool

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
		GameState.highest_views = maxf(amt, GameState.highest_views)
		views_changed.emit(amt)
signal views_changed(amt: float)

var peak_viewers : float:
	set(amt):
		peak_viewers = amt
		peak_viewers_changed.emit(amt)
		GameState.highest_viewers = maxf(amt, GameState.highest_viewers)
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

var ability_revenue : float

var total_revenue : float

var damage_tick_timer : float

var prev_viewers : float

var times_hit_goal : float
signal goal_hit


func _ready():
	GameState.stream_manager = self
	GlobalSignals.ability_applied.connect(apply_ability)
	GlobalSignals.character_died.connect(on_character_died)
	GlobalSignals.player_character_died.connect(on_player_character_died)
	GlobalSignals.stream_started.connect(start_stream)
	GlobalSignals.stream_end_anim_finished.connect(show_orig_team)

	GlobalSignals.stream_results_confirmed.connect(reset_stats)
	GameState.subscribers_changed.connect(on_subscribers_changed)

	get_viewport().size_changed.connect(on_viewport_size_changed)
	hide_teams()


func _physics_process(delta : float):
	if not in_stream:
		return
	views += randfn(views_per_sec * delta, (views_per_sec * delta) * 0.5)

	peak_viewers = maxf(viewers, peak_viewers)
	if viewers != prev_viewers and can_tick:
		var lerp_weight := viewers / (2.0 * viewer_goal)
		var pitch := minf(lerpf(tick_start_pitch, tick_end_pitch, lerp_weight), tick_end_pitch)
		SoundManager.play_sound(tick_sound, 0.0, pitch, tick_volume)
		can_tick = false
		get_tree().create_timer(tick_debounce_time, true, true, true).timeout.connect(func(): can_tick = true)
	prev_viewers = viewers

	if hp_drain_increase_started:
		hp_drain_increase_timer += delta
		if hp_drain_increase_timer >= hp_drain_increase_interval:
			hp_drain += 1
			hp_drain_increase_timer -= hp_drain_increase_interval

	damage_tick_timer += delta
	if damage_tick_timer >= 1.0:
		damage_all_characters(hp_drain)
		damage_tick_timer -= 1.0

	update_times_hit_goal()
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
	GlobalSignals.subscribers_gained.emit(amt_gained)


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
	peak_viewers = 0
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
	ability_revenue = 0

	self.times_hit_goal = 0

	self.hp_drain = 1
	self.hp_drain_increase_timer = 0.0
	self.hp_drain_increase_started = false



func start_stream():
	reset_stats()
	viewer_goal = GameState.viewer_goal

	clear_teams()
	original_player_team.clear()
	for slot in GameState.main_slots.slots:
		if slot.slot_obj is Character:
			original_player_team.append(slot.slot_obj)
			var dupe_char : Character = slot.slot_obj.my_duplicate()
			dupe_char.set_meta(&"slot_index", slot.slot_index)
			player_team.append(dupe_char)
	hide_orig_team()
	show_teams()
	for char in player_team:
		char.drag_component.draggable = false
		character_container.add_child(char)
		var slot_index : int = char.get_meta(&"slot_index", 0)
		GameState.main_slots.set_char_visual_pos(char, slot_index)
		char.setup_abilities()
		char.in_stream = true
		char.died.connect(kill_character.bind(char))
	in_stream = true
	proc_start_stream_items()
	apply_front_character_items()
	can_tick = true
	get_tree().create_timer(self.hp_drain_increase_start_delay, false, true).timeout.connect(func():
		self.hp_drain_increase_started = true
	)
	# stream starts -> viewport size changes -> slot positions update on one frame,
	# so we need to set the positions on the next frame
	call_deferred("on_viewport_size_changed")
	GlobalSignals.stream_setup_finished.emit()


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
	self.handle_unique_ability_logic(ability, caster_statuses, caster)
	for effect in ability.ability_effects:
		if randf() > effect.chance:
			continue
		var new_stat_change := effect.stat_change.duplicate()
		if effect.stat_scaling:
			var amount_add := calc_stat_scaling_amount(effect.stat_scaling, caster)
			new_stat_change.amount += amount_add
		apply_stat_change(new_stat_change, caster)


func apply_stat_change(stat_change : StatValue, caster : Character):
	var amount := stat_change.amount
	match stat_change.stat:
		StatValue.Stat.VIEWS:
			self.views += amount
		StatValue.Stat.VIEWS_PER_SEC:
			self.views_per_sec += amount
		StatValue.Stat.VIEWER_RETENTION:
			self.viewer_retention += amount
		StatValue.Stat.VIEWERS:
			self.viewers += amount
		StatValue.Stat.SUBSCRIBER_RATE:
			self.subscriber_rate += amount
		StatValue.Stat.SUBSCRIBERS:
			GameState.subscribers += amount
		StatValue.Stat.MEMBER_RATE:
			self.member_rate += amount
		StatValue.Stat.MEMBERS:
			GameState.members += amount
		StatValue.Stat.STAMINA:
			caster.hp = mini(caster.hp + int(amount), caster.max_hp)
		StatValue.Stat.MONEY:
			GameState.player_money += amount
			self.ability_revenue += amount
		_:
			print_debug("Couldn't match stat: %s" % stat_change.stat)
	GlobalSignals.show_stream_stat_value.emit(stat_change, caster.global_position)


func calc_stat_scaling_amount(stat_scaling: StatValue, caster: Character) -> float:
	var amt : float = 0
	match stat_scaling.stat:
		StatValue.Stat.VIEWS:
			amt += self.views * stat_scaling.amount
		StatValue.Stat.VIEWS_PER_SEC:
			amt += self.views_per_sec * stat_scaling.amount
		StatValue.Stat.VIEWER_RETENTION:
			amt += self.viewer_retention * stat_scaling.amount
		StatValue.Stat.VIEWERS:
			amt += self.viewers * stat_scaling.amount
		StatValue.Stat.SUBSCRIBER_RATE:
			amt += self.subscriber_rate * stat_scaling.amount
		StatValue.Stat.SUBSCRIBERS:
			amt += GameState.subscribers * stat_scaling.amount
		StatValue.Stat.MEMBER_RATE:
			amt += self.member_rate * stat_scaling.amount
		StatValue.Stat.MEMBERS:
			amt += GameState.members * stat_scaling.amount
		StatValue.Stat.STAMINA:
			amt += caster.hp * stat_scaling.amount
		StatValue.Stat.MONEY:
			amt += GameState.player_money * stat_scaling.amount
	return amt


func handle_unique_ability_logic(ability: AbilityDefinition, caster_statuses: Dictionary, caster: Character):
	match ability.ability_id:
		&"energy_drink":
			var heal_amount : int = ability.ability_data.get('heal_amount', 0)
			ability.ability_data.set('heal_amount', max(heal_amount - 1, 0))
			var stat_change := StatValue.new()
			stat_change.stat = StatValue.Stat.STAMINA
			stat_change.amount = heal_amount
			apply_stat_change(stat_change, caster)


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
	char.setup_abilities()
	char.in_stream = true
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


func on_viewport_size_changed():
	for char in player_team:
		var slot_index : int = char.get_meta(&"slot_index", 0)
		GameState.main_slots.set_char_visual_pos(char, slot_index)


func check_stream_over():
	if not player_team.is_empty():
		return
	for char in player_team:
		char.stop_timers()
	for char in enemy_team:
		char.stop_timers()
	in_stream = false
	self.update_revenue()
	if self.peak_viewers >= GameState.viewer_goal:
		GlobalSignals.stream_ended.emit(true)
	else:
		GlobalSignals.stream_ended.emit(false)
		GlobalSignals.viewer_goal_failed.emit()


func update_revenue() -> void:
	self.ad_revenue = self.views * self.ad_rpm / 1000.0
	self.member_revenue = self.revenue_per_member * GameState.members
	self.total_revenue = self.get_total_revenue()


func get_total_revenue() -> float:
	return self.get_performance_bonus() + self.ad_revenue + self.member_revenue


func update_times_hit_goal():
	var prev_times := times_hit_goal
	times_hit_goal = floorf(self.peak_viewers / self.viewer_goal)
	if times_hit_goal > prev_times:
		goal_hit.emit()


func get_performance_bonus() -> float:
	self.update_times_hit_goal()
	return self.base_revenue * times_hit_goal


func proc_end_combat_items():
	for item in GameState.items.get_items(&"hp_gain"):
		GameState.main_slots.foreach_slot_obj(func(char: Character):
			char.add_max_hp(2)
		)
