extends Resource

class_name ItemDefinition

# id used to check for items in code
@export var name : StringName
@export var display_name : String
@export var item_sprite : Texture2D
@export var sprite_scale : Vector2 = Vector2.ONE
@export var description_text : String
@export var price : int
@export var sell_price : int
@export var properties : Dictionary
