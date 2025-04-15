extends SubViewportContainer

@export var preview_center : Control
@export var preview_container : Control
@export var base_size : Vector2 = Vector2(1280, 720)

@export var in_stream_parent : Node
var out_stream_parent : Node

var in_stream : bool

func _ready() -> void:
	GlobalSignals.stream_started.connect(move_to_top_layer)
	GlobalSignals.stream_results_confirmed.connect(move_to_kbs_window)
	self.out_stream_parent = self.get_parent()
	self.in_stream = false


func _process(delta: float) -> void:
	if self.in_stream:
		var window := get_window()
		self.size = window.size
		self.position = Vector2.ZERO
	else:
		update_size()
		var final_scale := self.size * self.scale
		self.global_position = preview_center.global_position - final_scale / 2.


func update_size():
	# maintain aspect ratio
	var aspect_ratio := base_size.x / base_size.y
	var window_size := get_viewport_rect().size
	var target_rect_size := preview_container.get_rect().size
	var target_size_x : float = minf(target_rect_size.x, target_rect_size.y * aspect_ratio)
	var new_scale : float = target_size_x / base_size.x
	self.scale = Vector2(new_scale, new_scale)
	self.update_minimum_size()


func move_to_top_layer():
	self.reparent(self.in_stream_parent)
	self.in_stream_parent.move_child(self, 0)
	self.scale = Vector2.ONE
	self.size = self.in_stream_parent.get_viewport().get_visible_rect().size
	self.position = Vector2.ZERO
	self.in_stream = true


func move_to_kbs_window():
	self.reparent(self.out_stream_parent)
	self.size = self.base_size
	self.in_stream = false
