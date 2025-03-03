extends UniqueStatus

class_name SummonOnDeath


@export var summons : Array[CharacterDefinition]
var tooltip_text_template := "On death, summon %s."


func _init() -> void:
	self.name = &"SummonOnDeath"
	self.display_name = "Summon on Death"


func get_tooltip_text() -> String:
	return tooltip_text_template % get_summon_names()


func get_summon_names() -> String:
	var summon_names := summons.map(func(char_def : CharacterDefinition):
		return char_def.character_name
	)
	return ", ".join(summon_names)
