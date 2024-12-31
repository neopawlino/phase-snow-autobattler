extends Node2D

class_name Character

@export var sprite : Sprite2D
@export var anim_player : AnimationPlayer
@export var anim_delay : float = 0.2

@export var base_scale : float = 0.25
@export var mouseover_scale : float = 1.1

@export var damage_numbers_origin : Node2D

# draggable stuff
var draggable : bool = false
var mouseover : bool = false
var drag_offset : Vector2
var drag_initial_pos : Vector2

var cur_character_slot : CharacterSlot

# gameplay stuff
enum Team {
	PLAYER,
	ENEMY,
}

var max_hp : int
var hp : int

var abilities: Array[Ability]

# character's position (index) in the team
var pos : int
var team : int

func _process(delta):
	if mouseover and draggable:
		if Input.is_action_just_pressed("click") and not GameState.is_dragging:
			drag_initial_pos = global_position
			drag_offset = get_global_mouse_position() - global_position
			GameState.is_dragging = true
			GameState.drag_char = self
			GameState.drag_original_char_slot = cur_character_slot
		if Input.is_action_pressed("click") and GameState.drag_char == self:
			global_position = get_global_mouse_position() - drag_offset
		elif Input.is_action_just_released("click"):
			GameState.is_dragging = false
			GameState.drag_char = null
			var tween = get_tree().create_tween()
			if GameState.drag_end_char_slot and not GameState.drag_end_char_slot.character:
				# dragging to an empty slot
				# TODO update order in TeamManager
				GameState.slots.set_char_pos(self, GameState.drag_end_char_slot.slot_index)
				self.cur_character_slot = GameState.drag_end_char_slot
				GameState.drag_original_char_slot.character = null
				GameState.drag_end_char_slot.character = self
				tween.tween_property(self, "global_position", GameState.drag_end_char_slot.global_position, 0.2).set_ease(Tween.EASE_OUT)
			elif GameState.drag_original_char_slot:
				# dragging nowhere in particular, or letting go after swapping
				tween.tween_property(self, "global_position", GameState.drag_original_char_slot.global_position, 0.2).set_ease(Tween.EASE_OUT)


# WE NEED TO USE THIS TO DUPLICATE RESOURCES IN AN ARRAY
# https://github.com/godotengine/godot/issues/74918
func my_duplicate() -> Character:
	var new_char := self.duplicate()
	new_char.abilities = self.abilities.duplicate(true)
	new_char.max_hp = self.max_hp
	new_char.hp = self.max_hp
	new_char.pos = self.pos
	new_char.team = self.team
	return new_char


func load_from_character_definition(char_def : CharacterDefinition):
	self.max_hp = char_def.max_hp
	self.hp = max_hp
	self.abilities = char_def.abilities.duplicate(true)
	sprite.texture = char_def.character_sprite


func make_timers():
	for ability : Ability in abilities:
		var timer := Timer.new()
		var ability_char := char
		var cur_ability := ability
		timer.wait_time = ability.cooldown
		timer.timeout.connect(func():
			var effective_range := cur_ability.ability_range - self.pos
			if effective_range <= 0:
				return
			anim_player.play(&"attack")
			await get_tree().create_timer(anim_delay).timeout
			if self.is_inside_tree():
				cast_ability(cur_ability)
		)
		timer.autostart = true
		self.add_child(timer)


func stop_timers():
	for node in self.get_children():
		if node is Timer:
			node.stop()


func cast_ability(ability: Ability):
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


func receive_ability(ability: Ability):
	if ability.physical_damage > 0:
		self.hp -= ability.physical_damage
		DamageNumbers.display_number(ability.physical_damage, damage_numbers_origin.global_position)


func _on_area_2d_mouse_entered() -> void:
	if not GameState.is_dragging:
		mouseover = true
		if draggable:
			sprite.scale = Vector2.ONE * base_scale * mouseover_scale


func _on_area_2d_mouse_exited() -> void:
	if not GameState.is_dragging:
		mouseover = false
		if draggable:
			sprite.scale = Vector2.ONE * base_scale
