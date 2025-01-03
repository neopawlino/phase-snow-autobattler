extends Node

class_name ShopManager

@export var shop_ui : Control
@export var combat_manager : CombatManager

var shop_slots : Array[CharacterSlot]

@export var shop_slot_count : int = 2
@export var buy_price : int = 3
@export var base_reroll_price : int = 2
@export var reroll_increase : int = 1

var reroll_price : int:
	set(value):
		reroll_price = value
		reroll_button.text = "Reroll: $%s" % reroll_price
		update_reroll_button_enabled(GameState.player_money)

@export var shop_slot_container : BoxContainer

var character_scene : PackedScene = preload("res://character.tscn")
var character_slot_scene : PackedScene = preload("res://character_slot.tscn")

@export var character_container : Control

@export var reroll_button : Button

@export var starting_money : int = 5
@export var starting_hp : int = 10

var all_characters_rg : ResourceGroup = load("res://all_characters.tres")
var all_character_definitions : Array[CharacterDefinition]


func _ready() -> void:
	all_characters_rg.load_all_into(all_character_definitions)
	for i in range(shop_slot_count):
		var slot : CharacterSlot = character_slot_scene.instantiate()
		slot.set_pickable(false)
		slot.slot_index = i
		shop_slots.append(slot)
		shop_slot_container.add_child(slot)
	GameState.player_money_changed.connect(update_reroll_button_enabled)
	GameState.player_money_changed.connect(update_shop_draggable)
	GameState.player_money = starting_money
	GameState.player_hp = starting_hp
	reset_reroll_price()
	call_deferred("reroll_characters")


func update_reroll_button_enabled(money: int = GameState.player_money):
	reroll_button.disabled = money < reroll_price


func update_shop_draggable(money: int = GameState.player_money):
	for slot in shop_slots:
		if not slot.character:
			continue
		slot.character.draggable = slot.character.can_afford(money)


func reset_reroll_price():
	reroll_price = base_reroll_price


func reroll_characters(increase_reroll_price : bool = false):
	if increase_reroll_price:
		reroll_price += reroll_increase
	for i in range(shop_slot_count):
		var slot := shop_slots[i]
		if slot.character:
			slot.character.queue_free()
		var char := character_scene.instantiate()
		char.load_from_character_definition(all_character_definitions.pick_random())
		add_character_to_slot(char, slot, buy_price)
	update_shop_draggable()


func add_character_to_slot(char: Character, slot : CharacterSlot, buy_price : int):
	char.team = Character.Team.PLAYER
	char.pos = slot.slot_index
	char.cur_character_slot = slot
	slot.character = char
	char.draggable = true

	char.from_shop = true
	char.buy_price = buy_price

	char.global_position = slot.global_position
	self.character_container.add_child(char)


func show_shop():
	shop_ui.show()
	shop_slot_container.show()


func _on_button_pressed() -> void:
	shop_ui.hide()
	shop_slot_container.hide()
	combat_manager.start_combat()


func _on_reroll_button_pressed() -> void:
	if reroll_price > GameState.player_money:
		# button should be disabled
		assert(false)
	GameState.player_money -= reroll_price
	reroll_characters(true)
