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

@export var ability_bar_container : BoxContainer

@export var price_color : Color = Color.WHITE
@export var price_unaffordable_color : Color = Color.INDIAN_RED

var ability_bar_scene : PackedScene = preload("res://ability_bar.tscn")

# draggable stuff
var draggable : bool = false
var mouseover : bool = false
var drag_offset : Vector2
var drag_initial_pos : Vector2

var cur_character_slot : CharacterSlot

var visual_position : Vector2

var base_scale : Vector2 = Vector2.ONE
var pos_offset : Vector2

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
var ability_timers : Array[Timer]
var ability_bars : Array[ProgressBar]

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

var last_tween : Tween


func _ready() -> void:
	visual_position = self.global_position
	GameState.player_money_changed.connect(update_price_color)
	set_price_visible(from_shop)


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
			GameState.drag_can_swap = not from_shop
		if Input.is_action_pressed("click") and GameState.drag_char == self:
			global_position = get_global_mouse_position() - drag_offset
		elif Input.is_action_just_released("click"):
			GameState.is_dragging = false
			GameState.drag_char = null
			if last_tween:
				last_tween.kill()
			last_tween = get_tree().create_tween()
			if GameState.drag_end_char_slot and not GameState.drag_end_char_slot.character:
				# dragging to an empty slot
				GameState.slots.set_char_pos(self, GameState.drag_end_char_slot.slot_index)
				self.cur_character_slot = GameState.drag_end_char_slot
				GameState.drag_original_char_slot.character = null
				GameState.drag_end_char_slot.character = self
				if from_shop:
					# buy the character
					GameState.player_money -= buy_price
					from_shop = false
				last_tween.tween_property(self, "global_position", GameState.drag_end_char_slot.global_position, 0.2).set_ease(Tween.EASE_OUT)
			elif GameState.drag_original_char_slot:
				# dragging nowhere in particular, or letting go after swapping
				last_tween.tween_property(self, "global_position", GameState.drag_original_char_slot.global_position, 0.2).set_ease(Tween.EASE_OUT)
				GameState.drag_original_char_slot = null


func set_flipped(flipped: bool):
	if flipped:
		base_scale.x = -abs(base_scale.x)
	else:
		base_scale.x = abs(base_scale.x)
	sprite.scale = base_scale
	sprite.position.x = -pos_offset.x


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


# WE NEED TO USE THIS TO DUPLICATE RESOURCES IN AN ARRAY
# https://github.com/godotengine/godot/issues/74918
func my_duplicate() -> Character:
	var new_char := self.duplicate()
	new_char.abilities = self.abilities.duplicate(true)
	new_char.ability_levels = self.ability_levels.duplicate()
	new_char.max_hp = self.max_hp
	new_char.hp = self.max_hp
	new_char.pos = self.pos
	new_char.team = self.team
	return new_char


func load_from_character_definition(char_def : CharacterDefinition):
	self.max_hp = char_def.max_hp
	self.hp = max_hp
	self.abilities = char_def.abilities.duplicate(true)
	self.ability_levels = []
	assert(!abilities.is_empty())
	for ability in abilities:
		self.ability_levels.append(0)
	self.ability_levels[0] = 1
	sprite.texture = char_def.character_sprite
	pos_offset = char_def.sprite_pos_offset
	sprite.position = char_def.sprite_pos_offset
	sprite.hframes = char_def.sprite_hframes

	sprite.scale = char_def.sprite_scale
	base_scale = char_def.sprite_scale


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
	var target_team : int = Team.ENEMY if team == Team.PLAYER else Team.PLAYER
	var targets : Array[int] = []
	var effective_range := ability.ability_range - self.pos
	var pierce := ability.pierce
	var i := 0
	while i < effective_range and pierce >= 0:
		targets.append(i)
		i += 1
		pierce -= 1
	if not targets.is_empty():
		GlobalSignals.ability_applied.emit(ability, target_team, targets)


func receive_ability(ability: AbilityLevel):
	if ability.physical_damage > 0:
		self.hp -= ability.physical_damage
		DamageNumbers.display_number(ability.physical_damage, damage_numbers_origin.global_position)


func set_price_visible(is_visible: bool):
	price.visible = is_visible


func set_price_text(value: int):
	price_label.text = str(value)


func can_afford(money: int) -> bool:
	return buy_price <= money


func update_price_color(money: int):
	set_price_color(can_afford(money))


func set_price_color(affordable : bool):
	var color := price_color if affordable else price_unaffordable_color
	price_label.add_theme_color_override(&"font_color", color)


func _on_area_2d_mouse_entered() -> void:
	if not GameState.is_dragging:
		mouseover = true
		if draggable:
			sprite.scale = base_scale * mouseover_scale


func _on_area_2d_mouse_exited() -> void:
	if not GameState.is_dragging:
		mouseover = false
		if draggable:
			sprite.scale = base_scale
