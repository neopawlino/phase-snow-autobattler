extends Control
class_name CustomTooltip

@export var title_label : Label
@export var description_label : RichTextLabel
@export var cooldown_label : Label
@export var cooldown_container : Control


func update_from_item_definition(item_def : ItemDefinition):
	title_label.text = item_def.display_name
	description_label.text = item_def.description_text
	cooldown_container.hide()


func update_from_character_definition(char_def : CharacterDefinition):
	title_label.text = char_def.character_name
	description_label.text = char_def.character_name
	cooldown_container.hide()


func update_from_ability_definition(ability_def : AbilityDefinition):
	title_label.text = ability_def.ability_name
	description_label.text = ability_def.description
	cooldown_label.text = "%.1fs" % ability_def.cooldown
	cooldown_container.show()
