extends SubViewportContainer


func _ready() -> void:
	get_window().size_changed.connect(update_size)
	update_size()


func update_size():
	var window := get_window()
	self.size = window.size
	self.position = -window.size / 2
