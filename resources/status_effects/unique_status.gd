extends Resource

class_name UniqueStatus

var name : StringName
var display_name : String
@export var icon : Texture2D


func get_tooltip_text() -> String:
	return "You shouldn't be seeing this! (someone forgot to override get_tooltip_text for this status)"
