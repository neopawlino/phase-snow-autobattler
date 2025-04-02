extends Control

class_name Ability

@export var drag_component : Draggable
@export var icon : TextureRect
@export var ability_definition : AbilityDefinition
@export var progress_bar : ProgressBar

var is_ability_reward : bool

func _ready() -> void:
	drag_component.drag_ended.connect(on_drag_ended)
	drag_component.mouseover_changed.connect(on_mouseover_changed)
	drag_component.drag_started.connect(on_drag_started)
	if ability_definition:
		icon.texture = ability_definition.icon


func on_drag_started():
	if not is_ability_reward:
		return
	self.is_ability_reward = false
	drag_component.on_drag_release()
	self.move_to_slot(GameState.ability_slots.get_next_free_slot(), true)
	GlobalSignals.rewards_screen_finished.emit()


func on_drag_ended():
	if GameState.drag_end_slot and GameState.drag_end_slot.slot_obj:
		# TODO swap
		pass
	elif GameState.drag_end_slot and not GameState.drag_end_slot.slot_obj:
		self.move_to_slot(GameState.drag_end_slot)
	elif GameState.drag_original_slot:
		# dragging nowhere in particular, or letting go after swapping
		self.global_position = GameState.drag_original_slot.global_position
		GameState.drag_original_slot = null


func move_to_slot(slot : Slot, use_tween : bool = false):
	if self.drag_component.cur_slot:
		self.drag_component.cur_slot.slot_obj = null
	self.reparent(slot)
	if use_tween:
		var tween := self.create_tween()
		tween.tween_property(self, "global_position", slot.global_position, 1.0).set_trans(Tween.TRANS_QUAD)
	else:
		self.global_position = slot.global_position
	slot.slot_obj = self
	self.drag_component.cur_slot = slot


func on_mouseover_changed(is_mouseover : bool):
	if is_mouseover:
		var rect_offset := drag_component.size / 2
		#Popups.update_from_ability_definition(ability_definition)
		#Popups.show_item_popup(Rect2i(Vector2i(drag_component.global_position - rect_offset), Vector2i(drag_component.size)))
	else:
		#Popups.hide_item_popup()
		pass
