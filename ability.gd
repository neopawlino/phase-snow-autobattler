extends Control

class_name Ability

@export var drag_component : Draggable
@export var icon : TextureRect
@export var ability_definition : AbilityDefinition
@export var progress_bar : ProgressBar

var is_ability_reward : bool

func _ready() -> void:
	drag_component.drag_started.connect(on_drag_started)
	if ability_definition:
		icon.texture = ability_definition.icon


func on_drag_started():
	if not is_ability_reward:
		return
	self.is_ability_reward = false
	self.drag_component.on_drag_release()
	self.drag_component.move_to_slot(GameState.ability_slots.get_next_free_slot(), true)
	GlobalSignals.rewards_screen_finished.emit()
