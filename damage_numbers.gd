extends Node

# based on a tutorial by DashNothing
# https://www.youtube.com/watch?v=F0DQLSiLkjg

func display_number(value: int, pos: Vector2):
	var number := Label.new()
	number.global_position = pos
	number.text = str(value)
	number.z_index = 5
	number.label_settings = LabelSettings.new()
	
	var color = "#FFF"
	# color logic based on damage type
	number.label_settings.font_color = color
	number.label_settings.font_size = 32
	number.label_settings.outline_color = "#000"
	number.label_settings.outline_size = 8
	
	call_deferred(&"add_child", number)
	
	await number.resized
	number.pivot_offset = Vector2(number.size / 2)
	
	var tween := get_tree().create_tween()
	tween.set_parallel(true)
	const max_x_offset := 64
	var x_offset = randf() * max_x_offset * (1 if randi_range(0, 1) == 0 else -1)
	tween.tween_property(
		number, "position:y", number.position.y - 64, 0.15
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		number, "position:x", number.position.x + x_offset, 0.75
	).set_ease(Tween.EASE_IN)
	tween.tween_property(
		number, "position:y", number.position.y, 0.5
	).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(
		number, "scale", Vector2.ZERO, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	await tween.finished
	number.queue_free()
