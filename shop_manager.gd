extends Node

class_name ShopManager

@export var shop_ui : Control
@export var stream_manager : StreamManager

var shop_slots : Array[Slot]
var item_slots : Array[Slot]

@export var shop_slot_count : int = 2
@export var item_slot_count : int = 2
@export var buy_price : int = 3
@export var base_reroll_price : int = 2
@export var reroll_increase : int = 1

var reroll_price : int:
	set(value):
		reroll_price = value
		reroll_button.text = "Reroll: $%s" % reroll_price
		update_reroll_button_enabled(GameState.player_money)

@export var shop_slot_container : Container
@export var item_slot_container : Container

var character_scene : PackedScene = preload("res://character.tscn")
var item_scene : PackedScene = preload("res://item.tscn")
var slot_scene : PackedScene = preload("res://character_slot.tscn")

@export var character_container : Control
@export var item_container : Control

@export var reroll_button : Button

@export var starting_money : int = 5

var all_characters_rg : ResourceGroup = load("res://all_characters.tres")
var all_character_definitions : Array[CharacterDefinition]

var all_items_rg : ResourceGroup = load("res://all_items.tres")
var all_item_definitions : Array[ItemDefinition]


func _ready() -> void:
	all_characters_rg.load_all_into(all_character_definitions)
	all_items_rg.load_all_into(all_item_definitions)

	for i in range(shop_slot_count):
		var slot : Slot = slot_scene.instantiate()
		slot.set_pickable(false)
		slot.slot_index = i
		slot.slot_type = Slot.SlotType.CHARACTER
		shop_slots.append(slot)
		shop_slot_container.add_child(slot)

	for i in range(item_slot_count):
		var slot : Slot = slot_scene.instantiate()
		slot.set_pickable(false)
		slot.slot_index = i
		slot.slot_type = Slot.SlotType.ITEM
		item_slots.append(slot)
		item_slot_container.add_child(slot)

	GameState.player_money_changed.connect(update_reroll_button_enabled)
	GameState.player_money_changed.connect(update_shop_draggable)
	GameState.player_money = starting_money
	GameState.shop_manager = self
	reset_reroll_price()
	call_deferred("reroll_characters")
	call_deferred("reroll_items")


func update_reroll_button_enabled(money: float = GameState.player_money):
	reroll_button.disabled = money < reroll_price


func update_shop_draggable(money: float = GameState.player_money):
	for slot in shop_slots:
		if not slot.slot_obj:
			continue
		slot.slot_obj.drag_component.draggable = slot.slot_obj.can_afford(money)
	for slot in item_slots:
		if not slot.slot_obj:
			continue
		slot.slot_obj.drag_component.draggable = slot.slot_obj.can_afford(money)


func reset_reroll_price():
	reroll_price = base_reroll_price


func increase_reroll_price():
	reroll_price += reroll_increase


func reroll_characters():
	for slot in shop_slots:
		if slot.slot_obj:
			slot.slot_obj.queue_free()
		var char : Character = character_scene.instantiate()
		char.load_from_character_definition(all_character_definitions.pick_random())
		char.set_info_z_index(-1)
		add_character_to_slot(char, slot, buy_price)
	update_shop_draggable()


func reroll_items():
	for slot in item_slots:
		if slot.slot_obj:
			slot.slot_obj.queue_free()
		var item : Item = item_scene.instantiate()
		var item_def : ItemDefinition = all_item_definitions.pick_random()
		item.load_from_item_definition(item_def)
		add_item_to_slot(item, slot, item_def.price)
	update_shop_draggable()


func reroll_all():
	reroll_characters()
	reroll_items()


func add_character_to_slot(char: Character, slot : Slot, buy_price : int):
	char.team = Character.Team.PLAYER
	#char.pos = slot.slot_index
	char.drag_component.cur_slot = slot
	slot.slot_obj = char
	char.drag_component.draggable = true

	char.from_shop = true
	char.buy_price = buy_price

	char.global_position = slot.global_position
	self.character_container.add_child(char)


func add_item_to_slot(item : Item, slot : Slot, buy_price : int):
	item.cur_slot = slot
	slot.slot_obj = item
	item.drag_component.draggable = true

	item.from_shop = true
	item.buy_price = buy_price

	item.global_position = slot.global_position
	self.item_container.add_child(item)


func show_shop():
	shop_ui.show()
	shop_slot_container.show()
	item_slot_container.show()
	item_container.show()


func hide_shop():
	shop_ui.hide()
	shop_slot_container.hide()
	item_slot_container.hide()
	item_container.hide()


func _on_button_pressed() -> void:
	hide_shop()
	stream_manager.start_combat()


func _on_reroll_button_pressed() -> void:
	if reroll_price > GameState.player_money:
		# button should be disabled
		assert(false)
	GameState.player_money -= reroll_price
	increase_reroll_price()
	reroll_all()
