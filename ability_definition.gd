extends Resource

class_name AbilityDefinition

enum AbilityType {
	PHYSICAL,
	TOXIC,
}

@export var ability_name : String
@export var ability_levels : Array[AbilityLevel]
