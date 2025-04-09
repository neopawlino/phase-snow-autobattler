extends Node

@export var decrease_button : Button
@export var increase_button : Button
@export var speed_label : Label


var speed_options : Array[int] = [
	1,
	2,
	4,
	8,
	16,
]

var speed_index : int
const SETTINGS_KEY : String = "stream_speed"


func _ready() -> void:
	self.increase_button.pressed.connect(increase_speed)
	self.decrease_button.pressed.connect(decrease_speed)
	self.speed_index = Settings.get_value(SETTINGS_KEY, 0)
	GlobalSignals.stream_started.connect(func():
		self.increase_button.disabled = false
		self.decrease_button.disabled = false
		self.set_speed(speed_index)
	)
	GlobalSignals.stream_ended.connect(func(_goal_met : bool):
		self.increase_button.disabled = true
		self.decrease_button.disabled = true
		self.set_speed(0)
	)


func on_pressed() -> void:
	self.speed_index = (speed_index + 1) % len(speed_options)
	self.set_speed(speed_index)
	self.save_speed(speed_index)


func increase_speed() -> void:
	self.speed_index = mini(speed_index + 1, len(speed_options) - 1)
	self.set_speed(speed_index)
	self.save_speed(speed_index)


func decrease_speed() -> void:
	self.speed_index = maxi(speed_index - 1, 0)
	self.set_speed(speed_index)
	self.save_speed(speed_index)


func set_speed(i : int) -> void:
	var speed := speed_options[i]
	var base_physics_tps : int = ProjectSettings.get_setting("physics/common/physics_ticks_per_second")
	Engine.time_scale = float(speed)
	Engine.physics_ticks_per_second = base_physics_tps * speed
	self.speed_label.text = "Speed: %dx" % speed


func save_speed(i : int) -> void:
	Settings.set_value(SETTINGS_KEY, i)
