extends Node

@export var viewport : SubViewport
@export var test_debug : bool


func _unhandled_input(event: InputEvent) -> void:
	if test_debug and event.is_action_pressed("click"):
		print('foo')
	viewport.push_input(event)
