extends Control

class_name StatusIcon

@export var icon : TextureRect
@export var value_label : Label

@export var pos_color : Color = Color.GREEN
@export var neg_color : Color = Color.RED

var value : int = 0:
	set(val):
		value = val
		update_value(val)

var status : StatusEffect.StatusId

var unique_status : UniqueStatus

static var status_icon_scene : PackedScene = preload("res://status_effects/StatusIcon.tscn")


static func make_status_icon(status : StatusEffect.StatusId, value : int = 0) -> StatusIcon:
	var status_icon : StatusIcon = status_icon_scene.instantiate()
	status_icon.status = status
	status_icon.icon.texture = StatusIconLib.get_icon_for_status(status)
	status_icon.value = value
	return status_icon


static func make_unique_status_icon(status: UniqueStatus) -> StatusIcon:
	var status_icon : StatusIcon = status_icon_scene.instantiate()
	status_icon.icon.texture = status.icon
	status_icon.unique_status = status
	status_icon.value = 0
	return status_icon


func update_value(val: int):
	self.visible = val != 0 or self.unique_status
	self.value_label.visible = val != 0
	value_label.text = str(val)
	value_label.add_theme_color_override(&"font_color", pos_color if val > 0 else neg_color)
	if not self.unique_status:
		self.tooltip_text = StatusIconLib.get_tooltip_text_for_status(self.status) % val
	else:
		self.tooltip_text = self.unique_status.get_tooltip_text()
