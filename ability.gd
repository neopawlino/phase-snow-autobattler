extends Resource

class_name Ability

enum AbilityType {
	PHYSICAL,
	TOXIC,
}

@export var ability_name : String
@export var ability_type : AbilityType
@export var physical_damage : int
@export var toxic_damage : int
@export var cooldown : float
@export var ability_range : int
@export var pierce : int
