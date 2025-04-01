extends Resource

class_name AbilityDefinition

@export var ability_name : String
@export var icon : Texture2D
@export var description : String
@export var stat_changes : Array[StatValue]

@export var cooldown : float = 1.0

@export var scaling : Array[StatValue]
@export var ability_keys : Array[StringName]
