extends Control

class_name ResultScreen


@onready var result_label : Label = %ResultLabel


func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_packed(load("res://main_menu.tscn"))
