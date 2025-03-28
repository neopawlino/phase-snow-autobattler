extends SubViewport

func _ready() -> void:
	get_window().size_changed.connect(size_to_window_size)
	size_to_window_size()


func size_to_window_size():
	self.size = get_window().size
