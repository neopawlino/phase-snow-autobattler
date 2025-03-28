extends Node

@export var stream_viewport_texture : TextureRect

func _ready() -> void:
	GlobalSignals.stream_started.connect(show_stream_viewport)
	GlobalSignals.stream_results_confirmed.connect(hide_stream_viewport)


func show_stream_viewport():
	stream_viewport_texture.show()


func hide_stream_viewport():
	stream_viewport_texture.hide()
