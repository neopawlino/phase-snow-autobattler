extends Node

@export var player_team : Array[Character]
@export var enemy_team : Array[Character]

var timers : Array[Timer]


func _ready():
	start_combat()


func start_combat():
	for char in player_team:
		char.cur_hp = char.max_hp
		for ability : Ability in char.abilities:
			var timer := Timer.new()
			var ability_char := char
			var cur_ability := ability
			timer.wait_time = ability.cooldown
			timer.timeout.connect(func():
				var char_index := player_team.find(ability_char)
				# TODO some logic for range stuff and finding targets
				var targets : Array[Character] = []
				if not enemy_team.is_empty():
					targets.append(enemy_team[0])
				apply_ability(cur_ability, targets)
			)
			timer.set_meta(&"char", char)
			timers.append(timer)
	for char in enemy_team:
		char.cur_hp = char.max_hp
		for ability : Ability in char.abilities:
			var timer := Timer.new()
			var ability_char := char
			var cur_ability := ability
			timer.wait_time = ability.cooldown
			timer.timeout.connect(func():
				var char_index := enemy_team.find(ability_char)
				# TODO some logic for range stuff and finding targets
				var targets : Array[Character] = []
				if not player_team.is_empty():
					targets.append(player_team[0])
				apply_ability(cur_ability, targets)
			)
			timer.set_meta(&"char", char)
			timers.append(timer)
	for timer in timers:
		timer.autostart = true
		self.add_child(timer)


func apply_ability(ability: Ability, targets: Array[Character]):
	print(targets)
	for char in targets:
		char.cur_hp -= ability.physical_damage
		if char.cur_hp <= 0:
			kill_character(char)


func kill_character(char: Character):
	var player_index := player_team.find(char)
	var enemy_index := enemy_team.find(char)
	if player_index >= 0:
		player_team.remove_at(player_index)
		print("Player dead")
	elif enemy_index >= 0:
		enemy_team.remove_at(enemy_index)
		print("Enemy dead")
	else:
		push_error("Couldn't find character to kill")
		assert(false)
	var char_timers = timers.filter(func(t: Timer): return t.get_meta(&"char") == char)
	for timer in char_timers:
		var timer_idx := timers.find(timer)
		timers[timer_idx].queue_free()
		timers.remove_at(timer_idx)
