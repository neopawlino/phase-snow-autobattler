extends Window


func _ready() -> void:
	size_changed.connect(clamp_to_viewport)
	GlobalSignals.stream_anim_started.connect(disable_interactable)
	GlobalSignals.rewards_screen_finished.connect(enable_interactable)
	close_requested.connect(on_close_requested)


func _process(delta: float) -> void:
	clamp_to_viewport()


func clamp_to_viewport():
	const margin := Vector4(40, 20, 20, 20) # top right bottom left
	var viewport_size : Vector2 = Vector2(get_parent().size)
	size.x = min(size.x, viewport_size.x - (margin.y + margin.w))
	size.y = min(size.y, viewport_size.y - (margin.x + margin.z))
	position.x = clamp(position.x, margin.w, viewport_size.x - margin.y - size.x)
	position.y = clamp(position.y, margin.x, viewport_size.y - margin.z - size.y)


func disable_interactable():
	self.unresizable = true
	self.unfocusable = true
	self.gui_disable_input = true


func enable_interactable():
	self.unresizable = false
	self.unfocusable = false
	self.gui_disable_input = false


func on_close_requested():
	self.visible = false
