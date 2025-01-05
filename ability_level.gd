extends Resource

class_name AbilityLevel

enum AbilityType {
	PHYSICAL,
	TOXIC,
}

static var ability_type_names : Dictionary = {
	AbilityType.PHYSICAL: "Physical",
	AbilityType.TOXIC: "Toxic"
}

@export var ability_type : AbilityType
@export var physical_damage : int
@export var cooldown : float
@export var ability_range : int
@export var pierce : int
@export var applied_statuses : Array[StatusEffect]


static func ability_type_to_str(ability_type: AbilityType) -> String:
	return ability_type_names[ability_type]
