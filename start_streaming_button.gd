extends Button

func _ready() -> void:
	self.pressed.connect(func():
		GlobalSignals.stream_anim_started.emit()
	)
	GlobalSignals.stream_results_confirmed.connect(func():
		self.set_pressed_no_signal(false)
	)
