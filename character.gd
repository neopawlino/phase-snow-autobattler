extends Node2D

class_name Character

@export var sprite : Sprite2D
@export var anim_player : AnimationPlayer

@export var visual : Node2D

@export var anim_delay : float = 0.2


@export var mouseover_scale : float = 1.1

@export var visual_follow_speed : float = 30

@export var damage_numbers_origin : Node2D

@export var price_label : Label
@export var price : Node2D

@export var hp_label : Label
@export var hp_bar : ProgressBar

@export var level_label : Label

@export var xp_label : Label
@export var xp_bar : ProgressBar

@export var ability_bar_container : BoxContainer

@export var price_color : Color = Color.WHITE
@export var price_unaffordable_color : Color = Color.INDIAN_RED

@export var character_tooltip : CharacterTooltip

var ability_bar_scene : PackedScene = preload("res://ability_bar.tscn")

var character_name : String

# draggable stuff
var draggable : bool = false
var mouseover : bool = false
var drag_offset : Vector2
var drag_initial_pos : Vector2

var cur_character_slot : CharacterSlot

var visual_position : Vector2

var base_scale : Vector2 = Vector2.ONE
var pos_offset : Vector2
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
		hp = value
		update_hp_bar(hp, max_hp)


var abilities : Array[AbilityDefinition]
var ability_levels : Array[int]
signal ability_levels_changed(levels : Array[int])

var cur_level : int = 0:
	set(value):
		cur_level = value
		update_level_label(value)
		update_xp_bar(xp)
var xp : int = 0:
	set(value):
		xp = value
		update_xp_bar(value)
var level_requirements : Array[int]
var levels : Array[CharacterLevel]

var skill_points : int = 0:
	set(value):
		skill_points = value
		update_skill_points(value)
		skill_points_changed.emit(value)
signal skill_points_changed(value : int)

var ability_timers : Array[Timer]
var ability_bars : Array[ProgressBar]

# StatusId -> int (number of stacks)
var statuses : Dictionary
# StatusId -> StatusIcon (that has been added to status icon container)
var status_icons : Dictionary

@export var status_icon_container : Container

# character's position (index) in the team
var pos : int
var team : int


var from_shop : bool:
	set(value):
		from_shop = value
		set_price_visible(value)
var buy_price : int:
	set(value):
		buy_price = value
		set_price_text(value)
		update_price_color(GameState.player_money)
var sell_price : int = 2

var last_tween : Tween

var tooltip_was_visible : bool


@onready var skill_points_label : Label = %SkillPointsLabel
@onready var select_container : Container = %SelectContainer


func _ready() -> void:
	visual_position = self.global_position
	GameState.player_money_changed.connect(update_price_color)
	GameState.is_dragging_changed.connect(set_container_mouse_filter)
	GlobalSignals.character_tooltip_opened.connect(func(): character_tooltip.visible = false)
	set_price_visible(from_shop)
	update_hp_bar(hp, max_hp)
	update_xp_bar(xp)
	update_level_label(cur_level)
	update_skill_points(skill_points)


func _process(delta: float):
	update_visual_position(delta)
	update_ability_bars()
	if mouseover and draggable:
		if Input.is_action_just_pressed("click") and not GameState.is_dragging:
			drag_initial_pos = global_position
			drag_offset = get_global_mouse_position() - global_position
			GameState.is_dragging = true
			GameState.drag_char = self
			GameState.drag_original_char_slot = cur_character_slot
			GameState.drag_end_char_slot = cur_character_slot
			GameState.drag_can_swap = not from_shop
			GameState.drag_initial_mouse_pos = get_global_mouse_position()
			tooltip_was_visible = character_tooltip.visible
			character_tooltip.visible = false
		if Input.is_action_pressed("click") and GameState.drag_char == self:
			global_position = get_global_mouse_position() - drag_offset
		elif Input.is_action_just_released("click"):
			GameState.is_dragging = false
			GameState.drag_char = null
			if last_tween:
				last_tween.kill()
			if GameState.drag_sell_button and not from_shop:
				# sell the character
				GameState.player_money += sell_price
				if cur_character_slot:
					cur_character_slot.character = null
				self.queue_free()
				GameState.drag_sell_button = false
			elif GameState.drag_end_char_slot and GameState.drag_end_char_slot.character \
				and GameState.drag_end_char_slot.character.can_merge(self):
				if from_shop:
					# buy the character
					GameState.player_money -= buy_price
					from_shop = false
				GameState.drag_end_char_slot.character.add_xp(1)
				if cur_character_slot:
					cur_character_slot.character = null
				self.queue_free()
			elif GameState.drag_end_char_slot and not GameState.drag_end_char_slot.character:
				# dragging to an empty slot
				GameState.slots.move_to_slot(self, GameState.drag_end_char_slot.slot_index)
				if from_shop:
					# buy the character
					GameState.player_money -= buy_price
					from_shop = false
				last_tween = get_tree().create_tween()
				last_tween.tween_property(self, "global_position", GameState.drag_end_char_slot.global_position, 0.2).set_ease(Tween.EASE_OUT)
			elif GameState.drag_original_char_slot:
				# dragging nowhere in particular, or letting go after swapping
				last_tween = get_tree().create_tween()
				last_tween.tween_property(self, "global_position", GameState.drag_original_char_slot.global_position, 0.2).set_ease(Tween.EASE_OUT)
				GameState.drag_original_char_slot = null
				if GameState.drag_initial_mouse_pos.distance_to(get_global_mouse_position()) < 50.0:
					GlobalSignals.character_tooltip_opened.emit()
					character_tooltip.visible = !tooltip_was_visible


func set_container_mouse_filter(is_dragging: bool):
	select_container.mouse_filter = Control.MOUSE_FILTER_IGNORE if is_dragging else Control.MOUSE_FILTER_PASS


func set_flipped(flipped: bool):
	self.flipped = flipped
	if flipped:
		base_scale.x = -abs(base_scale.x)
		sprite.position.x = -pos_offset.x
	else:
		base_scale.x = abs(base_scale.x)
		sprite.position.x = pos_offset.x
	sprite.scale = base_scale


func update_visual_position(delta: float):
	var offset := global_position - visual_position
	visual_position += offset * visual_follow_speed * delta
	visual.global_position = visual_position


func update_ability_bars():
	# future: interpolate/smooth bar visual updates
	for i in range(len(ability_bars)):
		var ability_timer := ability_timers[i]
		var ability_bar := ability_bars[i]
		ability_bar.max_value = ability_timer.wait_time
		ability_bar.value = ability_timer.wait_time - ability_timer.time_left


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
		var xp_req := level_requirements[cur_level]
		xp_label.text = "%s/%s" % [xp, xp_req]
		xp_bar.max_value = xp_req
		xp_bar.value = xp


func update_level_label(level : int):
	level_label.text = "Lv.%s" % level


func update_skill_points(value : int):
	skill_points_label.visible = value > 0
	skill_points_label.text = "SP:%s" % value


# WE NEED TO USE THIS TO DUPLICATE RESOURCES IN AN ARRAY
# https://github.com/godotengine/godot/issues/74918
func my_duplicate() -> Character:
	var char_scene : PackedScene = preload("res://character.tscn")
	var new_char : Character = char_scene.instantiate()
	new_char.abilities = self.abilities.duplicate()
	new_char.ability_levels = self.ability_levels.duplicate()
	new_char.max_hp = self.max_hp
	new_char.hp = self.max_hp
	new_char.pos = self.pos
	new_char.team = self.team
	new_char.cur_level = self.cur_level
	new_char.xp = self.xp
	new_char.level_requirements = self.level_requirements.duplicate()
	new_char.levels = self.levels.duplicate()

	# ensure status icons get added
	# this might reorder status icons oh well
	for status_id in self.statuses:
		new_char.add_status(status_id, self.statuses[status_id])

	new_char.global_position = self.global_position
	new_char.visual_position = self.visual_position
	new_char.visual.global_position = self.visual.global_position
	new_char.sprite.texture = self.sprite.texture
	new_char.pos_offset = self.pos_offset
	new_char.sprite.position = self.pos_offset
	new_char.sprite.hframes = self.sprite.hframes

	new_char.sprite.scale = self.sprite.scale
	new_char.base_scale = self.base_scale
	new_char.set_flipped(flipped)

	return new_char


func load_from_character_definition(char_def : CharacterDefinition):
	self.character_name = char_def.character_name
	self.max_hp = char_def.max_hp
	self.hp = max_hp
	self.abilities = char_def.abilities.duplicate()
	self.ability_levels = char_def.initial_ability_levels.duplicate()
	self.levels = char_def.levels.duplicate()
	self.level_requirements = char_def.level_requirements.duplicate()
	self.cur_level = char_def.initial_level

	for status in char_def.statuses:
		self.add_status(status.status_id, status.value)

	sprite.texture = char_def.character_sprite
	pos_offset = char_def.sprite_pos_offset
	sprite.position = char_def.sprite_pos_offset
	sprite.hframes = char_def.sprite_hframes

	sprite.scale = char_def.sprite_scale
	base_scale = char_def.sprite_scale

	character_tooltip.load_char_def(char_def)


func add_xp(amount : int):
	if is_max_level():
		return
	var cur_level_req := level_requirements[cur_level]
	xp += amount
	skill_points += amount
	if xp >= cur_level_req:
		level_up()


func level_up():
	# index 0 == level 1, etc.
	var char_level : CharacterLevel = levels[cur_level]
	max_hp += char_level.hp
	hp += char_level.hp

	for status in char_level.statuses:
		self.add_status(status.status_id, status.value)

	var cur_level_req := level_requirements[cur_level]
	xp -= cur_level_req
	cur_level += 1


func level_up_ability(ability_index : int):
	skill_points -= 1
	ability_levels[ability_index] += 1
	ability_levels_changed.emit(ability_levels)


func make_timers():
	for i in range(len(abilities)):
		var ability_def := abilities[i]
		var ability_level_index := ability_levels[i] - 1
		if ability_level_index < 0:
			continue
		var ability_level := ability_def.ability_levels[ability_level_index]
		var timer := Timer.new()
		var ability_char := char
		timer.wait_time = ability_level.cooldown
		timer.timeout.connect(func():
			var effective_range := ability_level.ability_range - self.pos
			if effective_range <= 0:
				return
			anim_player.play(&"attack")
			await get_tree().create_timer(anim_delay).timeout
			if self.is_inside_tree():
				cast_ability(ability_level)
		)
		timer.autostart = true
		self.add_child(timer)
		self.ability_timers.append(timer)

		var ability_bar : ProgressBar = ability_bar_scene.instantiate()
		self.ability_bars.append(ability_bar)
		self.ability_bar_container.add_child(ability_bar)


func stop_timers():
	for timer in ability_timers:
		timer.stop()
		timer.queue_free()
	ability_timers.clear()

	for bar in ability_bars:
		bar.queue_free()
	ability_bars.clear()


func cast_ability(ability: AbilityLevel):
	var target_team : int = Team.ENEMY if self.team == Team.PLAYER else Team.PLAYER
	var targets : Array[int] = []

	if ability.ability_type == AbilityLevel.AbilityType.BUFF:
		target_team = self.team
		var start_index = maxi(0, self.pos - ability.ability_range)
		var end_index = mini(GameState.combat_manager.slots.max_slots, self.pos + ability.ability_range + 1)
		for i in range(start_index, end_index):
			targets.append(i)
	else:
		var effective_range := ability.ability_range - self.pos
		var pierce := ability.pierce
		var i := 0
		while i < effective_range and pierce >= 0:
			if i >= GameState.combat_manager.slots.max_slots:
				break
			targets.append(i)
			i += 1
			pierce -= 1

	if not targets.is_empty():
		GlobalSignals.ability_applied.emit(ability, target_team, targets, self.statuses)
		var toxic_value : int = get_status_value(StatusEffect.StatusId.TOXIC)
		if toxic_value > 0:
			self.hp -= toxic_value
			DamageNumbers.display_number(toxic_value, damage_numbers_origin.global_position)
			self.add_status(StatusEffect.StatusId.TOXIC, -1)
			GameState.combat_manager.check_character_dead(self)


func receive_ability(ability: AbilityLevel, caster_statuses: Dictionary):
	if ability.physical_damage > 0:
		var damage : int = ability.physical_damage + caster_statuses.get(StatusEffect.StatusId.STRENGTH, 0)
		if damage > 0:
			damage = max(1, damage - get_status_value(StatusEffect.StatusId.ARMOR))
		else:
			damage = max(0, damage - get_status_value(StatusEffect.StatusId.ARMOR))

		var envenom : int = caster_statuses.get(StatusEffect.StatusId.ENVENOM, 0)
		if envenom > 0:
			self.add_status(StatusEffect.StatusId.TOXIC, envenom)

		var armor_break : int = caster_statuses.get(StatusEffect.StatusId.ARMOR_BREAKER, 0)
		if armor_break > 0:
			self.add_status(StatusEffect.StatusId.ARMOR, -armor_break)

		self.hp -= damage
		DamageNumbers.display_number(damage, damage_numbers_origin.global_position)

	for status in ability.applied_statuses:
		self.add_status(status.status_id, status.value)


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


func get_income() -> int:
	var income := 0
	for i in range(len(abilities)):
		var ability_def := abilities[i]
		var ability_level_index := ability_levels[i] - 1
		if ability_level_index < 0:
			continue
		var ability_level := ability_def.ability_levels[ability_level_index]
		income += ability_level.income
	return income


func set_price_visible(is_visible: bool):
	price.visible = is_visible


func set_price_text(value: int):
	price_label.text = str(value)


func can_afford(money: int) -> bool:
	return buy_price <= money


func can_merge(other: Character) -> bool:
	return other != self and !is_max_level() and other.character_name == self.character_name


func is_max_level() -> bool:
	return cur_level >= len(levels)


func update_price_color(money: int):
	set_price_color(can_afford(money))


func set_price_color(affordable : bool):
	var color := price_color if affordable else price_unaffordable_color
	price_label.add_theme_color_override(&"font_color", color)


func _on_container_mouse_entered() -> void:
	if not GameState.is_dragging:
		mouseover = true
		if draggable:
			sprite.scale = base_scale * mouseover_scale


func _on_container_mouse_exited() -> void:
	if not GameState.is_dragging:
		mouseover = false
		if draggable:
			sprite.scale = base_scale
