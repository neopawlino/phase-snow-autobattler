extends Node

class_name ShopManager

var talent_slots : Array[ShopSlot]
var item_slots : Array[Slot]

@export var window : CustomWindow

@export var talent_slot_count : int = 3
@export var buy_price : float = 10
@export var base_reroll_price : float = 2
@export var reroll_increase : float = 1
@export var reroll_increase_mult : float = 1.3

@export var inflation_label : Label

var reroll_price : float:
	set(value):
		reroll_price = value
		update_reroll_button_enabled(GameState.player_money)
		update_reroll_button_text(value)

@export var talent_slot_container : Container

var character_scene : PackedScene = preload("res://src/character/character.tscn")
var shop_slot_scene : PackedScene = preload("res://src/shop/shop_slot.tscn")

@export var reroll_button : Button
@export var reroll_label : Label
@export var reroll_price_label : Label
@export var reroll_normal_text_color : Color = Color("0f1111")
@export var reroll_disabled_text_color : Color = Color("00000089")

@export var error_label : Label
var error_tween : Tween

@export var no_room_message : String = "No room in Bench!"

@export var cheats_container : Control


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

	GameState.shop_manager = self

	GameState.player_money_changed.connect(update_reroll_button_enabled)
	GameState.player_money_changed.connect(update_can_afford)
	GameState.inflation_changed.connect(update_inflation_label)
	GlobalSignals.stream_end_anim_finished.connect(reroll_talents)
	GlobalSignals.stream_end_anim_finished.connect(reset_reroll_price)
	GlobalSignals.stream_end_anim_finished.connect(window.notification.emit)

	cheats_container.visible = GameState.cheats_enabled
	GameState.cheats_enabled_changed.connect(func(enabled : bool):
		cheats_container.visible = enabled
	)

	window.notification.emit()

	reroll_button.pressed.connect(on_reroll_button_pressed)

	reset_reroll_price()
	update_inflation_label(GameState.inflation_coeff)
	error_label.hide()
	call_deferred("reroll_talents")


func update_inflation_label(val : float):
	if val >= 1e6:
		inflation_label.text = "x" + StringUtil.format_number(val)
	else:
		inflation_label.text = "x%.2f" % val


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
	character.set_ui_visible(true)
	slot.set_sold_out(true)


func update_reroll_button_enabled(money: float = GameState.player_money):
	var disabled := money < reroll_price
	reroll_button.disabled = disabled
	# text color
	var color := reroll_disabled_text_color if disabled else reroll_normal_text_color
	reroll_label.add_theme_color_override(&"font_color", color)
	reroll_price_label.add_theme_color_override(&"font_color", color)


func update_can_afford(player_money : float):
	for slot in self.talent_slots:
		if slot.slot_obj:
			slot.set_can_afford(slot.buy_price <= player_money)


func reset_reroll_price():
	reroll_price = base_reroll_price * GameState.inflation_coeff


func increase_reroll_price():
	reroll_price *= reroll_increase_mult
	reroll_price += reroll_increase


func update_reroll_button_text(value : float):
	reroll_price_label.text = "$%.2f" % value


func reroll_talents():
	for slot in talent_slots:
		if slot.slot_obj:
			slot.slot_obj.queue_free()
		var char : Character = character_scene.instantiate()
		char.load_from_character_definition(RandomUtil.all_character_definitions.pick_random())
		char.set_ui_visible(false)
		add_character_to_slot(char, slot, buy_price * GameState.inflation_coeff)


func reroll_all():
	reroll_talents()


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
	slot.set_can_afford(buy_price <= GameState.player_money)


func add_item_to_slot(item : Item, slot : Slot, buy_price : int):
	item.cur_slot = slot
	slot.slot_obj = item
	item.drag_component.draggable = true

	item.from_shop = true
	item.buy_price = buy_price

	item.global_position = slot.global_position
	self.item_container.add_child(item)


func show_error(message : String):
	error_label.text = message
	error_label.modulate.a = 1.0
	error_label.show()
	if error_tween:
		error_tween.kill()
	error_tween = self.create_tween()
	error_tween.tween_property(error_label, "modulate:a", 0.0, 1.0).set_delay(1.0)
	error_tween.tween_callback(error_label.hide)


func on_reroll_button_pressed() -> void:
	if reroll_price > GameState.player_money:
		# button should be disabled
		assert(false)
		return
	GameState.player_money -= reroll_price
	increase_reroll_price()
	reroll_all()
