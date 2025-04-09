extends Control

class_name Ability

@export var drag_component : Draggable
@export var icon : TextureRect
@export var ability_definition : AbilityDefinition
@export var progress_bar : ProgressBar

var is_ability_reward : bool

var sell_value : float = 3.0

func _ready() -> void:
	drag_component.drag_started.connect(on_drag_started)
	drag_component.drag_occupied_slot.connect(on_drag_occupied_slot)
	if ability_definition:
		icon.texture = ability_definition.icon


func on_drag_started():
	if not is_ability_reward:
		return
	self.is_ability_reward = false
	self.drag_component.on_drag_release()
	self.drag_component.move_to_slot(GameState.ability_slots.get_next_free_slot(), true)
	GlobalSignals.rewards_screen_finished.emit()


func on_drag_occupied_slot(slot : Slot):
	if not slot.slot_obj is Ability or slot.slot_obj == self:
		drag_component.move_to_original_slot()
		return
	# swap
	var other : Ability = slot.slot_obj
	drag_component.move_to_slot(slot)
	other.drag_component.move_to_slot(GameState.drag_original_slot)


func my_duplicate() -> Ability:
	var new_ability : Ability = self.duplicate()
	new_ability.ability_definition = self.ability_definition.duplicate(true)
	return new_ability
