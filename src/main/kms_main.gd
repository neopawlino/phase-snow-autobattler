extends Node2D

@export var kbs_window : Window

func _ready() -> void:
	get_viewport().gui_embed_subwindows = true
