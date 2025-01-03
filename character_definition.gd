extends Resource

class_name CharacterDefinition

@export var character_name : String
@export var character_sprite : Texture2D
@export var sprite_pos_offset : Vector2
@export var sprite_scale : Vector2 = Vector2.ONE
@export var sprite_hframes : int = 2

@export var max_hp : int
@export var abilities : Array[AbilityDefinition]
