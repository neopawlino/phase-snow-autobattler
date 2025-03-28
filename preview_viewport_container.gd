extends SubViewportContainer

@export var window : Window
@export var preview_container : Container
@export var preview_center : Control
@export var base_size : Vector2 = Vector2(1280, 720)
@export var camera : Camera2D
@export var bottom_margin : float = 100

func _ready() -> void:
	window.size_changed.connect(update_size)
	call_deferred(&"update_size")


func _process(delta: float) -> void:
	var final_scale := self.size * self.scale
	self.global_position = preview_center.global_position - final_scale / 2.


func update_size():
	# maintain aspect ratio
	var aspect_ratio := base_size.x / base_size.y
	var window_size := get_viewport_rect().size
	var target_size_x : float = minf(window_size.x, (window_size.y - bottom_margin) * aspect_ratio)
	var new_scale : float = target_size_x / base_size.x
	self.scale = Vector2(new_scale, new_scale)
	self.update_minimum_size()


func _on_button_pressed() -> void:
	# not done: disable inputs on windows etc during transition
	# zoom into me, then switch to a different viewport if necessary
	var root_size := camera.get_viewport_rect().size
	var dest_size := self.size * self.scale
	var zoom := root_size / dest_size
	# camera is centered but window's coordinates are from top left
	var window_offset := Vector2(window.position) - root_size / 2.0 + window.size / 2.0
	var preview_offset = preview_center.global_position - window.size / 2.0

	var tween := get_tree().create_tween()
	tween.tween_property(camera, "zoom", zoom, 1.0).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(camera, "offset", window_offset + preview_offset, 1.0).set_trans(Tween.TRANS_QUAD)

	GlobalSignals.stream_anim_started.emit()

	get_tree().create_timer(2.0).timeout.connect(func():
		var end_tween := get_tree().create_tween()
		end_tween.tween_property(camera, "zoom", Vector2(1.0, 1.0), 1.0).set_trans(Tween.TRANS_QUAD)
		end_tween.parallel().tween_property(camera, "offset", Vector2(0, 0), 1.0).set_trans(Tween.TRANS_QUAD)
		get_tree().create_timer(1.0).timeout.connect(func():
			GlobalSignals.rewards_screen_finished.emit()
		)
	)
