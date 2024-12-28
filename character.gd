extends Sprite2D

class_name Character

var max_hp : int
var hp : int

var abilities: Array[Ability]

# character's position (index) in the team
var pos : int
enum Team {
	PLAYER,
	ENEMY,
}
var team : int


func load_from_character_definition(char_def : CharacterDefinition):
	self.max_hp = char_def.max_hp
	self.hp = max_hp
	self.abilities = char_def.abilities.duplicate(true)
	self.texture = char_def.character_sprite
	self.scale = Vector2(0.5, 0.5)


func make_timers():
	for ability : Ability in abilities:
		var timer := Timer.new()
		var ability_char := char
		var cur_ability := ability
		timer.wait_time = ability.cooldown
		timer.timeout.connect(func():
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
				GlobalSignals.ability_applied.emit(cur_ability, target_team, targets)
		)
		timer.autostart = true
		self.add_child(timer)
