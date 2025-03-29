extends Node

@export var viewport : SubViewport


func _unhandled_input(event: InputEvent) -> void:
	viewport.push_input(event)
