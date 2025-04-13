extends Control
class_name AbilitySlots

@export var starting_slots : int = 8
@export var show_slot_indicator : bool = true

var ability_slot_scene := preload("res://src/ability/ability_slot.tscn")


func _ready() -> void:
	GameState.ability_slots = self
	for child in self.get_children():
		child.queue_free()
	for _i in range(starting_slots):
		self.add_slot()


func get_next_free_slot() -> Slot:
	for slot : Slot in self.get_children():
		if not slot.slot_obj:
			return slot
	return self.add_slot()


func add_slot() -> Slot:
	var new_slot : Slot = ability_slot_scene.instantiate()
	new_slot.show_slot_indicator = self.show_slot_indicator
	self.add_child(new_slot)
	return new_slot
