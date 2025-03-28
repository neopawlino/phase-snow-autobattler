extends Sprite2D

@export var main_viewport : SubViewport


func _unhandled_input(event: InputEvent) -> void:
	main_viewport.push_input(event)
