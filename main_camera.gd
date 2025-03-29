extends Camera2D


@export var preview_viewport_container : SubViewportContainer
@export var preview_center : Control
@export var kbs_window : Window


func _ready() -> void:
	GlobalSignals.stream_results_confirmed.connect(on_stream_results_confirmed)


func _on_start_streaming_button_pressed() -> void:
	# zoom into me, then switch to a different viewport if necessary
	var root_size := self.get_viewport_rect().size
	var dest_size := preview_viewport_container.size * preview_viewport_container.scale
	var target_zoom := root_size / dest_size
	target_zoom.x = min(target_zoom.x, target_zoom.y)
	target_zoom.y = min(target_zoom.x, target_zoom.y)
	# camera is centered but window's coordinates are from top left
	var window_offset := Vector2(kbs_window.position) - root_size / 2.0 + kbs_window.size / 2.0
	var preview_offset = preview_center.global_position - kbs_window.size / 2.0

	var tween := get_tree().create_tween()
	tween.tween_property(self, "zoom", target_zoom, 1.0).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(self, "offset", window_offset + preview_offset, 1.0).set_trans(Tween.TRANS_QUAD)

	GlobalSignals.stream_anim_started.emit()

	get_tree().create_timer(1.0).timeout.connect(func():
		GlobalSignals.stream_started.emit()
	)


func on_stream_results_confirmed() -> void:
	var end_tween := get_tree().create_tween()
	end_tween.tween_property(self, "zoom", Vector2(1.0, 1.0), 1.0).set_trans(Tween.TRANS_QUAD)
	end_tween.parallel().tween_property(self, "offset", Vector2(0, 0), 1.0).set_trans(Tween.TRANS_QUAD)
	get_tree().create_timer(1.0).timeout.connect(func():
		GlobalSignals.rewards_screen_finished.emit()
	)
