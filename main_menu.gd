extends Control

var main_scene : PackedScene = load("res://main.tscn")


func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(main_scene)
