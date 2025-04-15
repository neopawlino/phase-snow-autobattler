extends Camera2D

var viewport_base_size : Vector2
var base_zoom : Vector2

func _ready() -> void:
	ScreenSpaceUtil.stream_camera = self
	var viewport := get_viewport()
	self.viewport_base_size = viewport.size
	self.base_zoom = self.zoom
	viewport.size_changed.connect(on_viewport_size_changed)


func on_viewport_size_changed():
	var viewport := get_viewport()
	self.position = Vector2(viewport.size) / 2.0
	var zoom_ratio := Vector2(viewport.size) / self.viewport_base_size
	var target_zoom := self.base_zoom * zoom_ratio
	target_zoom.x = min(target_zoom.x, target_zoom.y)
	target_zoom.y = min(target_zoom.x, target_zoom.y)
	self.zoom = target_zoom
