extends Control

@export var window : CustomWindow

@export var abilities_container : Container

@export var title_label : Label
@export var ability_reward_control : Control

@export var skip_button : Button

var ability_scene := preload("res://src/ability/ability.tscn")

var num_choices : int = 3

func _ready() -> void:
	GlobalSignals.stream_end_anim_finished.connect(show_ability_reward)
	GlobalSignals.rewards_screen_finished.connect(close_ability_reward)
	skip_button.pressed.connect(close_ability_reward)
	self.close_ability_reward()
	self.ability_reward_control.hide()


func show_ability_reward():
	for child in abilities_container.get_children():
		child.queue_free()
	for ability_def in RandomUtil.random_abilities_no_dupes(num_choices):
		var ability : Ability = ability_scene.instantiate()
		ability.ability_definition = ability_def
		ability.is_ability_reward = true
		abilities_container.add_child(ability)
	self.show_anim()
	window.notification.emit()


func show_anim():
	var tween := self.create_tween()
	title_label.hide()
	title_label.modulate.a = 0
	skip_button.modulate.a = 0
	ability_reward_control.custom_minimum_size.x = 0
	ability_reward_control.show()
	abilities_container.show()
	tween.tween_property(ability_reward_control, "custom_minimum_size:x", 200, 0.4).set_trans(Tween.TransitionType.TRANS_QUAD)
	tween.tween_callback(title_label.show)
	tween.tween_property(title_label, "modulate:a", 1, 0.1)
	tween.set_parallel().tween_property(skip_button, "modulate:a", 1, 0.1)


func close_ability_reward():
	for child in abilities_container.get_children():
		child.queue_free()
	hide_anim()


func hide_anim():
	var tween := self.create_tween()
	tween.tween_property(title_label, "modulate:a", 0, 0.1)
	tween.set_parallel().tween_property(skip_button, "modulate:a", 0, 0.1)
	tween.set_parallel(false)
	tween.tween_callback(title_label.hide)
	tween.tween_property(ability_reward_control, "custom_minimum_size:x", 0, 0.4).set_trans(Tween.TransitionType.TRANS_QUAD)
	tween.tween_callback(ability_reward_control.hide)
