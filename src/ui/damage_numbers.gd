extends Node

@export var number_parent : Node

# based on a tutorial by DashNothing
# https://www.youtube.com/watch?v=F0DQLSiLkjg

func _ready() -> void:
	GlobalSignals.show_damage_number.connect(display_number)


func display_number(value: String, pos: Vector2, color : Color = Color.WHITE):
	var number := Label.new()
	number.process_mode = Node.PROCESS_MODE_ALWAYS
	number.global_position = pos
	number.text = value
	number.z_index = 5
	number.theme_type_variation = &"DamageNumber"
	number.add_theme_color_override(&"font_color", color)

	number_parent.call_deferred(&"add_child", number)

	await number.resized
	number.pivot_offset = Vector2(number.size / 2)
	number.global_position -= Vector2(number.size / 2)

	var tween := self.create_tween()
	tween.set_parallel(true)
	const max_x_offset := 32
	var x_offset = randf() * max_x_offset * (1 if randi_range(0, 1) == 0 else -1)
	tween.tween_property(
		number, "position:y", number.position.y - 128, 2.0
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		number, "position:x", number.position.x + x_offset, 2.0
	).set_ease(Tween.EASE_IN)
	tween.tween_property(
		number, "modulate", Color(1, 1, 1, 0), 1.0
	).set_delay(1.0)
	tween.tween_property(
		number, "scale", Vector2.ONE * 1.5, 0.02
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(
		number, "scale", Vector2.ONE, 0.4
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_delay(0.1)

	await tween.finished
	number.queue_free()
