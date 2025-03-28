extends Node

class_name TeamManager

@export var max_slots : int = 6

@export var initial_player_team : Array[CharacterDefinition]
@export var enemy_layouts : EnemyLayouts

@export var test_character : CharacterDefinition

var character_scene : PackedScene = preload("res://character.tscn")
var character_slot_scene : PackedScene = preload("res://character_slot.tscn")

# just used for visibility, not positioning
@export var character_container : Control

@export var slots : Slots


func _ready():
	# load after slots are set up
	call_deferred(&"load_initial_teams")

	GameState.round_number = 1
	GameState.wins_needed = enemy_layouts.wins_needed
	GameState.player_hp = enemy_layouts.initial_lives
	GameState.wins = 0
	GlobalSignals.stream_started.connect(hide_teams)


func load_initial_teams():
	var i : int = 0
	for char_def in initial_player_team:
		var char : Character = character_scene.instantiate()
		var slot := slots.player_team[i]
		char.load_from_character_definition(char_def)
		char.team = Character.Team.PLAYER
		char.pos = slot.slot_index
		char.cur_character_slot = slot
		char.drag_component.draggable = true

		char.global_position = slot.global_position
		slot.slot_obj = char
		self.character_container.add_child(char)
		i += 1
	load_enemy_team_for_round(GameState.round_number)


func load_enemy_team_for_round(round_number : int):
	clear_enemy_slots()
	var round_index := clampi(round_number - 1, 0, len(enemy_layouts.round_layouts) - 1)
	var enemy_team : EnemyTeam = enemy_layouts.round_layouts[round_index].enemy_teams.pick_random()
	var i := 0
	for char_def in enemy_team.characters:
		if i >= len(slots.enemy_team):
			push_warning("Enemy team with more characters than max slots")
			return
		var char : Character = character_scene.instantiate()
		var slot := slots.enemy_team[i]
		char.load_from_character_definition(char_def)
		char.team = Character.Team.ENEMY
		char.set_flipped(true)
		char.pos = slot.slot_index
		char.cur_character_slot = slot
		char.drag_component.draggable = false

		char.global_position = slot.global_position
		slot.slot_obj = char
		self.character_container.add_child(char)
		i += 1


func clear_enemy_slots():
	for slot in slots.enemy_team:
		if slot.slot_obj:
			slot.slot_obj.queue_free()
		slot.slot_obj = null


func add_test_character():
	var char : Character = character_scene.instantiate()
	var slot_i := 0
	var slot : Slot = null
	for cur_slot in slots.player_team:
		if not cur_slot.slot_obj:
			slot = cur_slot
			break
	if not slot:
		return
	char.load_from_character_definition(test_character)
	char.team = Character.Team.PLAYER
	char.pos = slot.slot_index
	char.cur_character_slot = slot
	slot.slot_obj = char
	char.drag_component.draggable = true

	char.global_position = slot.global_position
	self.character_container.add_child(char)


func hide_teams():
	character_container.visible = false


func show_teams():
	character_container.visible = true
