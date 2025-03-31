extends Button

func _ready() -> void:
	self.pressed.connect(func():
		GlobalSignals.stream_anim_started.emit()
	)
