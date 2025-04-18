extends Control

class_name Character

@export var max_level : int = 4

@export var sprite : CharacterSprite
@export var anim_player : AnimationPlayer

@export var visual : Node2D
@export var damage_audio : AudioStream
@export var die_audio : AudioStream
@export var level_up_audio : AudioStream
@export var xp_gain_audio : AudioStream

@export var mouseover_scale : float = 1.1

@export var damage_numbers_origin : Control

@export var hp_label : Label
@export var hp_bar : ProgressBar

@export var level_label : Label

@export var xp_label : Label
@export var xp_bar : ProgressBar

@export var name_label : Label

@export var char_info_container : Container

var ability_bar_scene : PackedScene = preload("res://src/ability/ability_bar.tscn")

var character_name : String

var idle_sprite_frame : int = 0
var drag_sprite_frame : int = 2
var sell_sprite_frame : int = 3

var FLASH_DURATION : float = 0.5

var base_scale : Vector2 = Vector2.ONE
var sprite_offset : Vector2
var flipped : bool

# gameplay stuff
enum Team {
	PLAYER,
	ENEMY,
}

var max_hp : int:
	set(value):
		max_hp = value
		update_hp_bar(hp, max_hp)
var hp : int:
	set(value):
		var old_hp := hp
		hp = value
		update_hp_bar(hp, max_hp)
		hp_changed.emit(hp, old_hp)
signal hp_changed(new_hp : int, old_hp : int)

var cur_level : int = 0:
	set(value):
		cur_level = value
		update_level_label(value)
		update_xp_bar(xp)
		cur_level_changed.emit(value)
signal cur_level_changed(value : int)
var xp : int = 0:
	set(value):
		xp = value
		update_xp_bar(value)
var total_xp : int = 0
var level_requirement : int = 1
var level_requirement_increase : int = 1
var hp_on_level_up : int

var abilities : Array[AbilityDefinition]

var ability_timers : Array[CustomTimer]

var ability_used_triggered : bool

# StatusId -> int (number of stacks)
var statuses : Dictionary
# StatusId -> StatusIcon (that has been added to status icon container)
var status_icons : Dictionary

var unique_statuses : Array[UniqueStatus]
var unique_status_icons : Array

@export var status_icon_container : Container

var team : int

var sell_value : float = 5.0

var was_tooltip_open_for_character : bool

var char_def : CharacterDefinition


@export var drag_component : Draggable

@export_storage var ability_slots : Array[Slot] = []
@export var ability_slot_container : Control
@export var ability_slot_grid_container : Control
@export var ability_grid_scroll_container : Control

@export var character_ui : Control


signal died
var is_dead : bool = false

var in_stream : bool = false

signal xp_gained
signal level_gained


static var character_scene : PackedScene = preload("res://src/character/character.tscn")
static var ability_slot_scene : PackedScene = preload("res://src/ability/ability_slot.tscn")

static func spawn_from_character_definition(char_def : CharacterDefinition) -> Character:
	var char : Character = character_scene.instantiate()
	char.load_from_character_definition(char_def)
	return char


func _ready() -> void:
	GlobalSignals.character_tooltip_opened.connect(func(char : Character):
		self.was_tooltip_open_for_character = char == self
	)
	GlobalSignals.stream_setup_finished.connect(on_stream_setup_finished)
	GlobalSignals.subscribers_gained.connect(on_subscribers_gained)
	update_hp_bar(hp, max_hp)
	update_xp_bar(xp)
	update_level_label(cur_level)
	drag_component.mouseover_changed.connect(func(is_mouseover):
		if is_mouseover and drag_component.draggable:
			self.sprite.scale = base_scale * mouseover_scale
		else:
			self.sprite.scale = base_scale
	)
	drag_component.drag_started.connect(func():
		GameState.drag_can_swap = true
	)
	drag_component.drag_ended.connect(handle_drag_ended)
	drag_component.drag_occupied_slot.connect(handle_drag_occupied_slot)


func _process(delta: float):
	if GameState.is_dragging and GameState.drag_object == self:
		if GameState.drag_sell_button:
			self.sprite.frame = sell_sprite_frame
		else:
			self.sprite.frame = drag_sprite_frame


func _physics_process(delta: float) -> void:
	ability_used_triggered = false


func get_pos() -> int:
	return self.drag_component.cur_slot.slot_index


func die(damage : int):
	var dir : float = 1.0 if self.team == Team.ENEMY else -1.0
	var lerp_weight : float = clampi(damage, 0, 100) / 100.0
	var force : float = lerp(250.0, 1500.0, lerp_weight)
	self.visual.play_death_anim(force * dir)
	self.visual.death_anim_finished.connect(func():
		get_tree().create_timer(1.0).timeout.connect(self.queue_free)
	)
	self.stop_timers()
	self.char_info_container.visible = false
	self.status_icon_container.visible = false

	SoundManager.play_sound(die_audio)


func handle_drag_ended():
	self.sprite.frame = idle_sprite_frame


func handle_drag_occupied_slot(slot : Slot):
	if slot.slot_obj is Character and slot.slot_obj.can_merge(self):
		# dragging onto same type: move to a signal, make the object handle it (character, item, ability)
		merge_character(GameState.drag_end_slot.slot_obj)
	elif slot.slot_obj == self:
		drag_component.move_to_original_slot()
	else:
		# swap
		var other : Character = slot.slot_obj
		drag_component.move_to_slot(slot)
		other.drag_component.move_to_slot(GameState.drag_original_slot)


func set_info_z_index(val : int):
	self.z_index = val
	self.sprite.z_index = val
	char_info_container.z_index = val


func set_ui_visible(val : bool):
	self.character_ui.visible = val


func set_flipped(flipped: bool):
	self.flipped = flipped
	if flipped:
		base_scale.x = -abs(base_scale.x)
	else:
		base_scale.x = abs(base_scale.x)
	sprite.scale = base_scale


func merge_character(other: Character):
	other.add_xp(self.total_xp + 1)
	remove_self()


func remove_self():
	if drag_component.cur_slot:
		drag_component.cur_slot.slot_obj = null
	move_abilities_to_inventory()
	self.queue_free()


func move_abilities_to_inventory():
	for slot in ability_slots:
		if slot.slot_obj:
			slot.slot_obj.move_to_inventory()


func update_hp_bar(hp : int, max_hp : int):
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	hp_label.text = "%s/%s" % [hp, max_hp]


func update_xp_bar(xp : int):
	if is_max_level():
		xp_label.text = "Max"
		xp_bar.max_value = 1
		xp_bar.value = 1
	else:
		xp_label.text = "%s/%s" % [xp, level_requirement]
		xp_bar.max_value = level_requirement
		xp_bar.value = xp


func update_level_label(level : int):
	level_label.text = "Lv.%s" % level


# WE NEED TO USE THIS TO DUPLICATE RESOURCES IN AN ARRAY
# https://github.com/godotengine/godot/issues/74918
func my_duplicate() -> Character:
	var char_scene : PackedScene = preload("res://src/character/character.tscn")
	var new_char : Character = char_scene.instantiate()
	new_char.max_hp = self.max_hp
	new_char.hp = self.max_hp
	new_char.team = self.team
	new_char.level_requirement = self.level_requirement
	new_char.cur_level = self.cur_level
	new_char.xp = self.xp

	new_char.char_def = self.char_def

	# ensure status icons get added
	# this might reorder status icons oh well
	for status in self.unique_statuses:
		new_char.add_unique_status(status)
	for status_id in self.statuses:
		new_char.add_status(status_id, self.statuses[status_id])

	# add abilities
	var abilities := self.get_abilities()
	var ability_slot_count = len(self.ability_slots)
	for i in range(ability_slot_count):
		new_char.add_ability_slot()
	for i in range(len(abilities)):
		var new_ability : Ability = abilities[i].my_duplicate()
		var new_slot := new_char.ability_slots[i]
		new_slot.slot_obj = new_ability
		new_slot.add_child(new_ability)
		new_ability.global_position = new_slot.global_position
		new_ability.drag_component.cur_slot = new_slot

	new_char.global_position = self.global_position
	new_char.visual.global_position = self.visual.global_position
	new_char.sprite.texture = self.sprite.texture
	new_char.sprite_offset = self.sprite_offset
	new_char.sprite.hframes = self.sprite.hframes

	new_char.sprite.scale = self.sprite.scale
	new_char.sprite.offset = self.sprite_offset
	new_char.base_scale = self.base_scale
	new_char.set_flipped(flipped)

	new_char.name_label.text = self.name_label.text

	new_char.abilities = self.abilities.duplicate(true)

	return new_char


func load_from_character_definition(char_def : CharacterDefinition):
	self.character_name = char_def.character_name
	self.max_hp = char_def.max_hp
	self.hp = max_hp
	self.hp_on_level_up = char_def.hp_on_level_up
	self.cur_level = char_def.initial_level

	for unique_status in char_def.unique_statuses:
		self.add_unique_status(unique_status)
	for status in char_def.statuses:
		self.add_status(status.status_id, status.value)

	sprite.texture = char_def.character_sprite
	sprite_offset = char_def.sprite_offset
	sprite.offset = char_def.sprite_offset
	sprite.hframes = char_def.sprite_hframes

	sprite.scale = char_def.sprite_scale
	base_scale = char_def.sprite_scale

	self.name_label.text = char_def.short_name

	self.abilities = char_def.abilities.duplicate(true)
	self.char_def = char_def


func add_xp(amount : int):
	if is_max_level():
		return
	xp += amount
	total_xp += amount
	if xp >= level_requirement:
		level_up()
	else:
		SoundManager.play_sound(xp_gain_audio)
	sell_value += 2.5
	xp_gained.emit()


func level_up():
	# index 0 == level 1, etc.
	max_hp += hp_on_level_up
	hp += hp_on_level_up

	self.add_ability_slot()

	xp -= level_requirement
	level_requirement += level_requirement_increase
	cur_level += 1
	SoundManager.play_sound(level_up_audio)
	level_gained.emit()


func add_max_hp(hp: int):
	self.max_hp += hp
	self.hp += hp


func get_abilities() -> Array[Ability]:
	var all_abilities : Array[Ability] = []
	for slot in ability_slots:
		if slot.slot_obj is Ability:
			all_abilities.append(slot.slot_obj)
	return all_abilities


func setup_abilities():
	for ability in self.get_abilities():
		setup_ability(ability.ability_definition, ability)
	for ability_def in self.abilities:
		setup_ability(ability_def)


func setup_ability(ability_def : AbilityDefinition, ability : Ability = null):
	match ability_def.trigger:
		AbilityDefinition.Trigger.COOLDOWN:
			self.make_ability_timer(ability_def, ability)
		_:
			pass


func make_ability_timer(ability_def : AbilityDefinition, ability : Ability = null):
	var timer := CustomTimer.new()
	var ability_char := char
	timer.wait_time = ability_def.cooldown
	timer.time_left = timer.wait_time
	timer.timeout.connect(cast_ability_with_anim.bind(ability_def, ability))
	timer.started = true
	if ability:
		timer.progress_bar = ability.progress_bar
	self.add_child(timer)
	self.ability_timers.append(timer)


func stop_timers():
	for timer in ability_timers:
		timer.queue_free()
	ability_timers.clear()


func on_stream_setup_finished():
	# trigger stream started abilities
	if not self.in_stream:
		return
	self.cast_abilities_of_trigger(AbilityDefinition.Trigger.STREAM_START)


func on_subscribers_gained(amt : float):
	if not self.in_stream:
		return
	self.cast_abilities_of_trigger(AbilityDefinition.Trigger.SUBSCRIBER_GAINED)


func cast_abilities_of_trigger(trigger : AbilityDefinition.Trigger):
	for ability in self.get_abilities():
		if ability.ability_definition.trigger == trigger:
			self.cast_ability_with_anim(ability.ability_definition, ability)
	for ability_def in self.abilities:
		if ability_def.trigger == trigger:
			self.cast_ability_with_anim(ability_def)


func on_ability_used(ability : AbilityDefinition):
	if ability.trigger == AbilityDefinition.Trigger.ABILITY_USED or self.ability_used_triggered:
		# on ability used can't trigger each other (easy infinite loop)
		return
	self.ability_used_triggered = true
	self.cast_abilities_of_trigger(AbilityDefinition.Trigger.ABILITY_USED)


func add_ability_slot():
	var new_slot := ability_slot_scene.instantiate()
	self.ability_slots.append(new_slot)
	if len(ability_slots) > 3:
		move_ability_slots_to_grid()
		ability_slot_grid_container.add_child(new_slot)
	else:
		ability_slot_container.add_child(new_slot)


func move_ability_slots_to_grid():
	for slot in ability_slots:
		if slot.get_parent() == ability_slot_container:
			slot.reparent(ability_slot_grid_container)
	ability_grid_scroll_container.show()


func cast_ability_with_anim(ability_def : AbilityDefinition, ability : Ability = null):
	if self.flipped:
		self.anim_player.play(&"attack_flipped")
	else:
		self.anim_player.play(&"attack")
	if self.is_inside_tree():
		var success := cast_ability(ability_def)
		if ability and success:
			var slot := ability.drag_component.cur_slot
			if slot:
				slot.play_anim()


func cast_ability(ability: AbilityDefinition) -> bool:
	if randf() > ability.cast_chance:
		return false
	GlobalSignals.ability_applied.emit(ability, self.statuses, self)
	self.on_ability_used(ability)
	return true


func receive_ability(ability: AbilityLevel, caster_statuses: Dictionary):
	if ability.physical_damage > 0:
		var damage : int = ability.physical_damage + caster_statuses.get(StatusEffect.StatusId.STRENGTH, 0)
		if damage > 0:
			damage = max(1, damage - get_status_value(StatusEffect.StatusId.ARMOR))
		else:
			damage = max(0, damage - get_status_value(StatusEffect.StatusId.ARMOR))
		take_damage(damage)

	var armor_break : int = caster_statuses.get(StatusEffect.StatusId.ARMOR_BREAKER, 0)
	if armor_break > 0 and ability.ability_type != AbilityLevel.AbilityType.BUFF:
		self.add_status(StatusEffect.StatusId.ARMOR, -armor_break)

	var envenom : int = caster_statuses.get(StatusEffect.StatusId.ENVENOM, 0)
	if envenom > 0 and ability.ability_type != AbilityLevel.AbilityType.BUFF:
		self.add_status(StatusEffect.StatusId.TOXIC, envenom)

	for status in ability.applied_statuses:
		self.add_status(status.status_id, status.value)


func take_damage(amount : int):
	self.hp -= amount
	GlobalSignals.show_stream_damage_number.emit(str(-amount), damage_numbers_origin.global_position, Color.FIREBRICK)
	sprite.damage_flash()
	sprite.damage_shake(6)
	SoundManager.play_sound(damage_audio)
	if self.hp <= 0 and not is_dead:
		died.emit()
		die(amount)


func add_status(status: StatusEffect.StatusId, value: int):
	var new_value : int = statuses.get(status, 0) + value
	statuses[status] = new_value
	if not status_icons.has(status):
		var icon := StatusIcon.make_status_icon(status, value)
		status_icon_container.add_child(icon)
		status_icons[status] = icon
	else:
		status_icons[status].value = new_value


func get_status_value(status: StatusEffect.StatusId) -> int:
	return statuses.get(status, 0)


func add_unique_status(status : UniqueStatus):
	unique_statuses.append(status)
	var icon := StatusIcon.make_unique_status_icon(status)
	status_icon_container.add_child(icon)
	unique_status_icons.append(icon)


func get_unique_statuses(status_name : StringName) -> Array[UniqueStatus]:
	return unique_statuses.filter(func(uniq_st : UniqueStatus):
		return uniq_st.name == status_name
	)


func get_income() -> int:
	var income := 0
	#for i in range(len(abilities)):
		#var ability_def := abilities[i]
		#var ability_level_index := ability_levels[i] - 1
		#if ability_level_index < 0:
			#continue
		#var ability_level := ability_def.ability_levels[ability_level_index]
		#income += ability_level.income
	return income


func can_merge(other: Character) -> bool:
	return other != null and other != self and !is_max_level() and other.character_name == self.character_name


func is_max_level() -> bool:
	return self.cur_level >= self.max_level and not GameState.cheat_remove_level_cap
