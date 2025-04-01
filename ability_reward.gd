extends Control

@export var abilities_container : Container

var ability_scene := preload("res://ability.tscn")

var num_choices : int = 3

func _ready() -> void:
	GlobalSignals.stream_results_confirmed.connect(show_ability_reward)
	GlobalSignals.rewards_screen_finished.connect(hide)
	# test
	show_ability_reward()


func show_ability_reward():
	for child in abilities_container.get_children():
		child.queue_free()
	for _i in range(num_choices):
		var ability : Ability = ability_scene.instantiate()
		ability.ability_definition = RandomUtil.random_ability()
		ability.is_ability_reward = true
		abilities_container.add_child(ability)
	self.show()
