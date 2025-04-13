extends Node

@export var number_parent : Node

@export var is_main_numbers : bool
@export var is_stream_numbers : bool

@export var stat_colors : Dictionary[StatValue.Stat, Color] = {
	StatValue.Stat.VIEWS: Color("ff4d4d"),
	StatValue.Stat.VIEWS_PER_SEC: Color("ff73c0"),
	StatValue.Stat.VIEWER_RETENTION: Color("ff8138"),
	StatValue.Stat.VIEWERS: Color("ffbe3d"),
	StatValue.Stat.SUBSCRIBER_RATE: Color("27c8d6"),
	StatValue.Stat.SUBSCRIBERS: Color("3d89d4"),
	StatValue.Stat.MEMBER_RATE: Color("2ed986"),
	StatValue.Stat.MEMBERS: Color("22ab24"),
	StatValue.Stat.STAMINA: Color("55f20c"),
	StatValue.Stat.MONEY: Color("ffff00"),
}

@export var prevent_overlap_offset : float = 30.0

class DamageNumber:
	var pos: Vector2
	var text : String
	var color : Color

var queued_numbers : Dictionary[Vector2, Array]

# based on a tutorial by DashNothing
# https://www.youtube.com/watch?v=F0DQLSiLkjg

func _ready() -> void:
	if self.is_main_numbers:
		GlobalSignals.show_main_stat_value.connect(queue_display_stat_value)
	if self.is_stream_numbers:
		GlobalSignals.show_stream_stat_value.connect(queue_display_stat_value)
		GlobalSignals.show_stream_damage_number.connect(queue_display_number)


func _physics_process(delta: float) -> void:
	for pos in queued_numbers:
		var nums : Array = queued_numbers[pos]
		var offset_y : float = 0.0
		for num in nums:
			num.pos.y += offset_y
			self.display_damage_number(num)
			offset_y -= prevent_overlap_offset
	queued_numbers.clear()


func queue_display_stat_value(stat_value : StatValue, pos : Vector2):
	var color : Color = self.stat_colors.get(stat_value.stat, Color.WHITE)
	var change_string := StringUtil.get_stat_change_string(stat_value)
	self.queue_display_number(change_string, pos, color)


func queue_display_number(value: String, pos: Vector2, color : Color = Color.WHITE):
	var pos_array : Array = self.queued_numbers.get_or_add(pos, [])
	var num := DamageNumber.new()
	num.text = value
	num.pos = pos
	num.color = color
	pos_array.append(num)


func display_damage_number(num : DamageNumber):
	self.display_number(num.text, num.pos, num.color)


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
