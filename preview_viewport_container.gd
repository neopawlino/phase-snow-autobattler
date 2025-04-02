extends SubViewportContainer

@export var preview_center : Control
@export var preview_container : Control
@export var base_size : Vector2 = Vector2(1280, 720)
@export var controls_container : Control


func _process(delta: float) -> void:
	update_size()
	var final_scale := self.size * self.scale
	self.global_position = preview_center.global_position - final_scale / 2.


func update_size():
	var bottom_margin := controls_container.custom_minimum_size.y
	# maintain aspect ratio
	var aspect_ratio := base_size.x / base_size.y
	var window_size := get_viewport_rect().size
	var target_rect_size := preview_container.get_rect().size
	var target_size_x : float = minf(target_rect_size.x, target_rect_size.y * aspect_ratio)
	var new_scale : float = target_size_x / base_size.x
	self.scale = Vector2(new_scale, new_scale)
	self.update_minimum_size()
