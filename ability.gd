extends Control

class_name Ability

@export var drag_component : Draggable
@export var icon : TextureRect
@export var ability_definition : AbilityDefinition

func _ready() -> void:
	drag_component.drag_ended.connect(on_drag_ended)
	drag_component.mouseover_changed.connect(on_mouseover_changed)
	if ability_definition:
		icon.texture = ability_definition.icon


func on_drag_ended():
	if GameState.drag_end_slot and GameState.drag_end_slot.slot_obj:
		# TODO swap
		pass
	elif GameState.drag_end_slot and not GameState.drag_end_slot.slot_obj:
		# dragging to an empty slot
		self.global_position = GameState.drag_end_slot.global_position
		self.reparent(GameState.drag_end_slot)
	elif GameState.drag_original_slot:
		# dragging nowhere in particular, or letting go after swapping
		self.global_position = GameState.drag_original_slot.global_position
		GameState.drag_original_slot = null


func on_mouseover_changed(is_mouseover : bool):
	if is_mouseover:
		var rect_offset := drag_component.size / 2
		Popups.update_from_ability_definition(ability_definition)
		Popups.show_item_popup(Rect2i(Vector2i(drag_component.global_position - rect_offset), Vector2i(drag_component.size)))
	else:
		Popups.hide_item_popup()
