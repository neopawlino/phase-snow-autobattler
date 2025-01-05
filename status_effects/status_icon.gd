extends Control

class_name StatusIcon

@export var icon : TextureRect
@export var value_label : Label

var value : int = 0:
	set(val):
		value = val
		update_value(val)


static var status_icon_scene : PackedScene = preload("res://status_effects/StatusIcon.tscn")


static func make_status_icon(status : StatusEffect.StatusId, value : int = 0) -> StatusIcon:
	var status_icon : StatusIcon = status_icon_scene.instantiate()
	status_icon.icon.texture = StatusIconLib.get_icon_for_status(status)
	status_icon.value = value
	return status_icon


func update_value(val: int):
	self.visible = val != 0
	value_label.text = str(val)
