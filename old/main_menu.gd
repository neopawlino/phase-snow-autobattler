extends Control

var main_scene : PackedScene = load("res://main.tscn")

@export var main_menu_container : Container
@export var options : OptionsMenu


func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(main_scene)


func _on_button_2_pressed() -> void:
	main_menu_container.hide()
	options.show()


func _on_options_menu_back_button_pressed() -> void:
	main_menu_container.show()
	options.hide()
