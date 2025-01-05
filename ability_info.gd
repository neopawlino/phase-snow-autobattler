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
@export var damage_label : RichTextLabel
@export var cooldown_label : RichTextLabel
@export var range_label : RichTextLabel
@export var pierce_label : RichTextLabel
@export var level_up_button : Button

@export var gray_on_locked : Array[Control]
@export var gray_color : Color = Color.DIM_GRAY

signal level_up_button_pressed


func set_level_up_button_disabled(disabled : bool):
	level_up_button.disabled = disabled


func is_max_level(level : int) -> bool:
	return level >= len(ability_def.ability_levels)


func update_visual():
	if not ability_def:
		return
	var cur_level : AbilityLevel = null
	var next_level : AbilityLevel = null
	if level > 0:
		cur_level = ability_def.ability_levels[level - 1]
		if not is_max_level(level):
			next_level = ability_def.ability_levels[level]
		level_up_button.text = "+"
		set_locked(false)
	else:
		cur_level = ability_def.ability_levels[0]
		level_up_button.text = "Unlock"
		set_locked(true)

	name_label.text = ability_def.ability_name
	level_label.text = "Lv.%s" % level
	type_label.text = AbilityLevel.ability_type_to_str(cur_level.ability_type)
	damage_label.visible = cur_level.physical_damage > 0
	damage_label.text = "Damage: %s" % cur_level.physical_damage
	cooldown_label.text = "Cooldown: %s" % cur_level.cooldown
	range_label.text = "Range: %s" % cur_level.ability_range
	pierce_label.visible = cur_level.pierce > 0
	pierce_label.text = "Pierce: %s" % cur_level.pierce

	if preview_levelup and next_level:
		pierce_label.visible = next_level.pierce > 0
		if next_level.physical_damage != cur_level.physical_damage:
			damage_label.text += "->[color=green]%s[/color]" % next_level.physical_damage
		if next_level.cooldown != cur_level.cooldown:
			cooldown_label.text += "->[color=green]%s[/color]" % next_level.cooldown
		if next_level.ability_range != cur_level.ability_range:
			range_label.text += "->[color=green]%s[/color]" % next_level.ability_range
		if next_level.pierce != cur_level.pierce:
			pierce_label.text += "->[color=green]%s[/color]" % next_level.pierce


func set_locked(locked: bool):
	for control in gray_on_locked:
		if locked:
			control.modulate = gray_color
		else:
			control.modulate = Color.WHITE


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
