extends Resource

class_name AbilityLevel

enum AbilityType {
	PHYSICAL,
	TOXIC,
}

@export var ability_type : AbilityType
@export var physical_damage : int
@export var cooldown : float
@export var ability_range : int
@export var pierce : int
