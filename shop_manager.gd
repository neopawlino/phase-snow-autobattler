extends Node

class_name ShopManager

@export var shop_ui : Control
@export var combat_manager : CombatManager

var shop_slots : Array[CharacterSlot]

@export var shop_slot_count : int = 2

@export var shop_slot_container : BoxContainer

var character_slot_scene : PackedScene = preload("res://character_slot.tscn")


func _ready() -> void:
	for i in range(shop_slot_count):
		var slot : CharacterSlot = character_slot_scene.instantiate()
		slot.set_pickable(false)
		slot.slot_index = i
		shop_slots.append(slot)
		shop_slot_container.add_child(slot)


func show_shop():
	shop_ui.show()


func _on_button_pressed() -> void:
	shop_ui.hide()
	combat_manager.start_combat()
