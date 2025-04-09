extends Control
class_name CustomTooltip

@export var title_label : Label
@export var description_label : RichTextLabel
@export var cooldown_label : Label
@export var cooldown_container : Control
@export var sell_value_label : Label

var item_def : ItemDefinition
var ability_def : AbilityDefinition

var update_per_frame : bool


func _physics_process(delta: float) -> void:
	if item_def:
		self.update_from_item_definition(item_def)
	if ability_def:
		self.update_from_ability_definition(ability_def)


func update_from_item_definition(item_def : ItemDefinition):
	title_label.text = item_def.display_name
	description_label.text = item_def.description_text
	cooldown_container.hide()
	self.item_def = item_def


func update_from_character_definition(char_def : CharacterDefinition):
	title_label.text = char_def.character_name
	cooldown_container.hide()


func update_from_ability_definition(ability_def : AbilityDefinition):
	title_label.text = ability_def.ability_name
	self.update_ability_description(ability_def)
	cooldown_label.text = "%.1fs" % ability_def.cooldown
	cooldown_container.show()
	self.ability_def = ability_def
	self.update_per_frame = true


func update_ability_description(ability_def : AbilityDefinition):
	self.description_label.text = ability_def.get_description()


func update_sell_value(sell_value : float):
	self.sell_value_label.visible = true
	self.sell_value_label.text = "Sell Value: %s" % StringUtil.format_money(sell_value)
