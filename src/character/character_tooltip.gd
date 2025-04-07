extends Control

class_name CharacterTooltip

@export var ability_info_scene : PackedScene
@export var name_label : Label
@export var sp_label : Label
@export var level_up_label : Label
@export var level_up_status_container : Container
@export var level_up_container : Container
@export var ability_info_container : Container

@export var char_tooltip_parent : Control

var character : Character

var char_def : CharacterDefinition

var ability_infos : Array[AbilityInfo]


func _ready() -> void:
	GameState.character_tooltip = self
	GlobalSignals.character_tooltip_opened.connect(load_char_and_show)


func _process(delta: float) -> void:
	if self.visible and Input.is_action_just_pressed(&"click"):
		var mouse_pos := self.get_global_mouse_position()
		var rect := self.get_global_rect()
		if !rect.has_point(mouse_pos):
			self.hide()


func load_char_and_show(char: Character):
	load_char(char)
	char_tooltip_parent.global_position = char.global_position
	self.show()


func update_all():
	#update_level_up_buttons(character.skill_points)
	update_skill_points(character.skill_points)
	update_ability_levels(character.ability_levels)
	update_char_level_bonuses(character.cur_level)


#func update_level_up_buttons(sp : int):
	#for i in range(len(ability_infos)):
		#var ability_level := character.ability_levels[i]
		#var info := ability_infos[i]
		#var disabled : bool = sp == 0 or info.is_max_level(ability_level)
		#info.set_level_up_button_disabled(disabled)
		#if info.preview_levelup:
			#info.preview_levelup = not disabled


func update_skill_points(sp : int):
	sp_label.visible = sp != 0
	sp_label.text = "Skill Points: %s" % sp


func update_ability_levels(levels : Array[int]):
	for i in range(len(ability_infos)):
		var info := ability_infos[i]
		info.level = levels[i]
	#update_level_up_buttons(character.skill_points)


func update_char_level_bonuses(level : int):
	if character.is_max_level():
		level_up_container.visible = false
		return
	var next_level := character.levels[character.cur_level]
	level_up_label.text = "On Level Up: +%sHP" % next_level.hp
	for child in level_up_status_container.get_children():
		child.queue_free()
	for status in next_level.statuses:
		var icon := StatusIcon.make_status_icon(status.status_id, status.value)
		level_up_status_container.add_child(icon)


func load_char(character : Character):
	self.character = character
	self.char_def = character.char_def
	self.name_label.text = char_def.character_name

	clear_abilities()

	for i in range(len(char_def.abilities)):
		var ability : AbilityDefinition = char_def.abilities[i]
		var ability_info : AbilityInfo = ability_info_scene.instantiate()
		ability_info.ability_index = i
		ability_info_container.add_child(ability_info)

		ability_info.ability_def = ability
		ability_info.level = character.ability_levels[i]

		ability_infos.append(ability_info)

		ability_info.level_up_button_pressed.connect(func():
			character.level_up_ability(ability_info.ability_index)
			update_all()
		)

	update_all()


func clear_abilities():
	for child in ability_info_container.get_children():
		child.queue_free()
	ability_infos.clear()
