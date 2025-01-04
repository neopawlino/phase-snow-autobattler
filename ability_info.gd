extends Control

class_name AbilityInfo

var ability_def : AbilityDefinition:
	set(ad):
		ability_def = ad
		update_visual()
var level : int:
	set(val):
		level = val
		update_visual()
var preview_levelup : bool = false

var ability_index : int

@export var name_label : Label
@export var level_label : Label
@export var type_label : Label
@export var damage_label : Label
@export var cooldown_label : Label
@export var range_label : Label
@export var pierce_label : Label
@export var level_up_button : Button

signal level_up_button_pressed


func set_level_up_button_disabled(disabled : bool):
	level_up_button.disabled = disabled


func is_max_level(level : int) -> bool:
	return level >= len(ability_def.ability_levels)


func update_visual():
	if not ability_def:
		return
	# TODO make preview level up do something, use richtextlabel
	var cur_level : AbilityLevel = null
	if level > 0:
		cur_level = ability_def.ability_levels[level - 1]
	else:
		cur_level = ability_def.ability_levels[0]
#		TODO gray out the ability info box on level 0 and make the button say "Unlock"
	name_label.text = ability_def.ability_name
	level_label.text = "Lv.%s" % level
	type_label.text = AbilityLevel.ability_type_to_str(cur_level.ability_type)
	damage_label.visible = cur_level.physical_damage > 0
	damage_label.text = "Damage: %s" % cur_level.physical_damage
	cooldown_label.text = "Cooldown: %s" % cur_level.cooldown
	range_label.text = "Range: %s" % cur_level.ability_range
	pierce_label.visible = cur_level.pierce > 0
	pierce_label.text = "Pierce: %s" % cur_level.pierce


func _on_level_up_button_mouse_entered() -> void:
	if level_up_button.disabled:
		return
	preview_levelup = true
	update_visual()


func _on_level_up_button_mouse_exited() -> void:
	preview_levelup = false
	update_visual()


func _on_level_up_button_pressed() -> void:
	level_up_button_pressed.emit()
