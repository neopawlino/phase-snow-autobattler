extends Sprite2D

class_name Character

@export var anim_player : AnimationPlayer
@export var anim_delay : float = 0.37

@export var damage_numbers_origin : Node2D

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
	self.texture = char_def.character_sprite


func make_timers():
	for ability : Ability in abilities:
		var timer := Timer.new()
		var ability_char := char
		var cur_ability := ability
		timer.wait_time = ability.cooldown
		timer.timeout.connect(func():
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
