extends Node2D

class_name Item

@export var price_label : Label
@export var price : Node2D

@export var price_color : Color = Color.WHITE
@export var price_unaffordable_color : Color = Color.INDIAN_RED

@export var drag_component : Draggable
@export var sprite : Sprite2D

@export var mouseover_scale : float = 1.1


var from_shop : bool:
	set(value):
		from_shop = value
		set_price_visible(value)
var buy_price : int:
	set(value):
		buy_price = value
		set_price_text(value)
		update_price_color(GameState.player_money)
var sell_price : int = 2

var base_scale : Vector2 = Vector2.ONE

var last_tween : Tween

var cur_slot : Slot:
	set(slot):
		cur_slot = slot
		self.drag_component.cur_slot = slot


@export var item_definition : ItemDefinition


func _ready() -> void:
	GameState.player_money_changed.connect(update_price_color)
	set_price_visible(from_shop)
	drag_component.mouseover_changed.connect(on_drag_component_mouseover_changed)
	drag_component.drag_started.connect(func():
		GameState.drag_can_swap = not from_shop
	)
	drag_component.drag_ended.connect(handle_drag_ended)


func on_drag_component_mouseover_changed(is_mouseover : bool):
	if is_mouseover:
		var rect_offset := drag_component.size / 2
		Popups.show_item_popup(Rect2i(Vector2i(drag_component.global_position - rect_offset), Vector2i(drag_component.size)), item_definition)
	else:
		Popups.hide_item_popup()
	if not drag_component.draggable:
		return
	if is_mouseover:
		self.sprite.scale = base_scale * mouseover_scale
	else:
		self.sprite.scale = base_scale

func handle_drag_ended():
	if last_tween:
		last_tween.kill()
	if GameState.drag_sell_button and not from_shop:
		self.sell_item()
	elif GameState.drag_end_slot and not GameState.drag_end_slot.slot_obj:
		# dragging to an empty slot
		GameState.items.move_to_slot(self, GameState.drag_end_slot.slot_index)
		if from_shop:
			buy_item()
		last_tween = get_tree().create_tween()
		last_tween.tween_property(self, "global_position", GameState.drag_end_slot.global_position, 0.2).set_ease(Tween.EASE_OUT)
	elif GameState.drag_original_slot:
		# dragging nowhere in particular, or letting go after swapping
		last_tween = get_tree().create_tween()
		last_tween.tween_property(self, "global_position", GameState.drag_original_slot.global_position, 0.2).set_ease(Tween.EASE_OUT)
		GameState.drag_original_slot = null


func buy_item():
	GameState.player_money -= buy_price
	from_shop = false
	self.reparent(GameState.items.items_container)


func sell_item():
	GameState.player_money += sell_price
	if cur_slot:
		cur_slot.slot_obj = null
	self.queue_free()
	GameState.drag_sell_button = false


func can_afford(money: int) -> bool:
	return buy_price <= money


func update_price_color(money: int):
	set_price_color(can_afford(money))


func set_price_color(affordable : bool):
	var color := price_color if affordable else price_unaffordable_color
	price_label.add_theme_color_override(&"font_color", color)


func set_price_visible(is_visible: bool):
	price.visible = is_visible


func set_price_text(value: int):
	price_label.text = str(value)


func load_from_item_definition(item_def : ItemDefinition):
	self.item_definition = item_def.duplicate(true)
	self.sprite.texture = item_def.item_sprite
	self.sprite.scale = item_def.sprite_scale
	self.buy_price = item_def.price
	self.sell_price = item_def.sell_price

	self.base_scale = item_def.sprite_scale
