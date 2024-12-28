extends Node

class_name ShopManager

@export var shop_ui : Control
@export var combat_manager : CombatManager


func show_shop():
	shop_ui.show()


func _on_button_pressed() -> void:
	shop_ui.hide()
	combat_manager.start_combat()
	
