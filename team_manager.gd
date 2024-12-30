extends Node

class_name TeamManager

@export var max_char_slots : int = 6

@export var initial_player_team : Array[CharacterDefinition]
@export var initial_enemy_team : Array[CharacterDefinition]

@export var test_character : CharacterDefinition

@export var character_scene : PackedScene
@export var character_slot_scene : PackedScene

var player_team : Array[Character]
var enemy_team : Array[Character]

# just used for visibility, not positioning
@export var character_container : Control

@export var slots : CharacterSlots


func _ready():
	call_deferred(&"load_initial_teams")
	GameState.team_manager = self


func load_initial_teams():
	var i : int = 0
	for char_def in initial_player_team:
		var char : Character = character_scene.instantiate()
		var slot := slots.player_team[i]
		char.load_from_character_definition(char_def)
		char.team = Character.Team.PLAYER
		char.pos = len(player_team)
		char.cur_character_slot = slot
		char.draggable = true
		player_team.append(char)

		char.global_position = slot.global_position
		self.character_container.add_child(char)
		i += 1
	i = 0
	for char_def in initial_enemy_team:
		var char : Character = character_scene.instantiate()
		var slot := slots.enemy_team[i]
		char.load_from_character_definition(char_def)
		char.team = Character.Team.ENEMY
		char.sprite.scale.x = char.base_scale * -1
		char.pos = len(enemy_team)
		char.cur_character_slot = slot
		char.draggable = false
		enemy_team.append(char)

		char.global_position = slot.global_position
		self.character_container.add_child(char)
		i += 1


func add_test_character():
	var char : Character = character_scene.instantiate()
	var slot_i := len(self.player_team)
	if slot_i >= max_char_slots:
		return
	var slot := slots.player_team[slot_i]
	char.load_from_character_definition(test_character)
	char.team = Character.Team.PLAYER
	char.pos = len(player_team)
	char.cur_character_slot = slot
	char.draggable = true
	player_team.append(char)

	char.global_position = slot.global_position
	self.character_container.add_child(char)


func hide_teams():
	character_container.visible = false


func show_teams():
	character_container.visible = true
