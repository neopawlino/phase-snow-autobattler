extends Button


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
	self.pressed.connect(on_pressed)
	self.speed_index = Settings.get_value(SETTINGS_KEY, 0)
	GlobalSignals.stream_started.connect(func():
		self.set_speed(speed_index)
		self.show()
	)
	GlobalSignals.stream_ended.connect(func(_result: CombatSummary.CombatResult, _money: int, _income: int, _hp_gain: int):
		self.set_speed(0)
		self.hide()
	)


func on_pressed() -> void:
	self.speed_index = (speed_index + 1) % len(speed_options)
	self.set_speed(speed_index)
	self.save_speed(speed_index)


func set_speed(i : int) -> void:
	var speed := speed_options[i]
	var base_physics_tps : int = ProjectSettings.get_setting("physics/common/physics_ticks_per_second")
	Engine.time_scale = float(speed)
	Engine.physics_ticks_per_second = base_physics_tps * speed
	self.text = "Speed: %dx" % speed


func save_speed(i : int) -> void:
	Settings.set_value(SETTINGS_KEY, i)
