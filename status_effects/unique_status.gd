extends Resource

class_name UniqueStatus

@export var name : StringName
@export var display_name : String
@export var tooltip_text : String
@export var icon : Texture2D


func get_tooltip_text() -> String:
	return tooltip_text
