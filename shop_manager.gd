extends Node

class_name ShopManager

var talent_slots : Array[ShopSlot]
var item_slots : Array[Slot]

@export var talent_slot_count : int = 3
#@export var item_slot_count : int = 2
@export var buy_price : float = 3
@export var base_reroll_price : int = 2
@export var reroll_increase : int = 1

#var reroll_price : int:
	#set(value):
		#reroll_price = value
		#reroll_button.text = "Reroll: $%s" % reroll_price
		#update_reroll_button_enabled(GameState.player_money)

@export var talent_slot_container : Container
#@export var item_slot_container : Container

var character_scene : PackedScene = preload("res://character.tscn")
var shop_slot_scene : PackedScene = preload("res://shop_slot.tscn")

#@export var reroll_button : Button


func _ready() -> void:
	for child in talent_slot_container.get_children():
		child.queue_free()

	for i in range(talent_slot_count):
		var slot : ShopSlot = shop_slot_scene.instantiate()
		slot.set_pickable(false)
		slot.slot_index = i
		slot.slot_type = Slot.SlotType.CHARACTER
		talent_slots.append(slot)
		talent_slot_container.add_child(slot)
		slot.buy_button_pressed.connect(on_talent_buy_button_pressed)

	#for i in range(item_slot_count):
		#var slot : Slot = slot_scene.instantiate()
		#slot.set_pickable(false)
		#slot.slot_index = i
		#slot.slot_type = Slot.SlotType.ITEM
		#item_slots.append(slot)
		#item_slot_container.add_child(slot)

	GameState.shop_manager = self
	#reset_reroll_price()
	call_deferred("reroll_talents")
	#call_deferred("reroll_items")


func on_talent_buy_button_pressed(slot : ShopSlot):
	assert(slot.slot_obj != null)
	if GameState.bench_slots.all_slots_full():
		# TODO no room anim
		return
	if GameState.player_money < slot.buy_price:
		# TODO can't afford anim or disable button state
		return
	GameState.player_money -= slot.buy_price
	var character : Character = slot.slot_obj
	GameState.bench_slots.push_char(character)
	character.drag_component.draggable = true
	slot.set_sold_out(true)


#func update_reroll_button_enabled(money: float = GameState.player_money):
	#reroll_button.disabled = money < reroll_price


#func reset_reroll_price():
	#reroll_price = base_reroll_price


#func increase_reroll_price():
	#reroll_price += reroll_increase


func reroll_talents():
	for slot in talent_slots:
		if slot.slot_obj:
			slot.slot_obj.queue_free()
		var char : Character = character_scene.instantiate()
		char.load_from_character_definition(RandomUtil.all_character_definitions.pick_random())
		add_character_to_slot(char, slot, buy_price)


#func reroll_items():
	#for slot in item_slots:
		#if slot.slot_obj:
			#slot.slot_obj.queue_free()
		#var item : Item = item_scene.instantiate()
		#var item_def : ItemDefinition = all_item_definitions.pick_random()
		#item.load_from_item_definition(item_def)
		#add_item_to_slot(item, slot, item_def.price)
	#update_shop_draggable()


func reroll_all():
	reroll_talents()
	#reroll_items()


func add_character_to_slot(char: Character, slot : ShopSlot, buy_price : float):
	char.team = Character.Team.PLAYER
	char.drag_component.cur_slot = slot
	slot.slot_obj = char
	char.drag_component.draggable = false

	char.global_position = slot.global_position
	slot.add_child(char)

	# slot logic
	slot.set_price(buy_price)
	slot.set_title(char.char_def.character_name)
	slot.set_sold_out(false)


func add_item_to_slot(item : Item, slot : Slot, buy_price : int):
	item.cur_slot = slot
	slot.slot_obj = item
	item.drag_component.draggable = true

	item.from_shop = true
	item.buy_price = buy_price

	item.global_position = slot.global_position
	self.item_container.add_child(item)


#func _on_reroll_button_pressed() -> void:
	#if reroll_price > GameState.player_money:
		## button should be disabled
		#assert(false)
	#GameState.player_money -= reroll_price
	#increase_reroll_price()
	#reroll_all()
