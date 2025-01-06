extends Resource

class_name CharacterDefinition

@export var character_name : String
@export var character_sprite : Texture2D
@export var sprite_offset : Vector2
@export var sprite_scale : Vector2 = Vector2.ONE
@export var sprite_hframes : int = 2

@export var max_hp : int
@export var abilities : Array[AbilityDefinition]
@export var level_requirements : Array[int]
@export var levels : Array[CharacterLevel]

@export var initial_level : int
@export var initial_ability_levels : Array[int]

@export var statuses : Array[StatusEffect]
