extends Node

var all_icons_rg : ResourceGroup = load("res://status_effects/all_status_icons.tres")

# StatusId -> Texture2D
var all_icons_dict : Dictionary = {}

func _ready() -> void:
	var all_icons_array : Array[StatusIconDefinition] = []
	all_icons_rg.load_all_into(all_icons_array)
	for icon_def in all_icons_array:
		all_icons_dict[icon_def.status] = icon_def.icon


func get_icon_for_status(status: StatusEffect.StatusId) -> Texture2D:
	return all_icons_dict[status]