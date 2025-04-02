extends Control
class_name CustomTooltip

@export var title_label : Label
@export var description_label : RichTextLabel
@export var cooldown_label : Label
@export var cooldown_container : Control

var item_def : ItemDefinition
var ability_def : AbilityDefinition

var update_per_frame : bool


func _process(delta: float) -> void:
	if not update_per_frame:
		return
	if item_def:
		self.update_from_item_definition(item_def)
	if ability_def:
		self.update_from_ability_definition(ability_def)


func update_from_item_definition(item_def : ItemDefinition):
	title_label.text = item_def.display_name
	description_label.text = item_def.description_text
	cooldown_container.hide()
	self.item_def = item_def
	self.update_per_frame = true


func update_from_character_definition(char_def : CharacterDefinition):
	title_label.text = char_def.character_name
	description_label.text = char_def.character_name
	cooldown_container.hide()


func update_from_ability_definition(ability_def : AbilityDefinition):
	title_label.text = ability_def.ability_name
	if ability_def.scaling.is_empty():
		description_label.text = ability_def.description
	else:
		description_label.text = ability_def.description % ability_def.get_format_string_values()
	cooldown_label.text = "%.1fs" % ability_def.cooldown
	cooldown_container.show()
	self.ability_def = ability_def
	self.update_per_frame = true
