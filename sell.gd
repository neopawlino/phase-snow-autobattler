extends Control


@onready var price_label : Label = %PriceLabel
@onready var box : PanelContainer = %SellContainer

var holding_sellable : bool = false

const c_normal_size : float = 1.0
const c_wombo_size : float = 1.1

func _ready() -> void:
	GameState.drag_object_changed.connect(update_price)


func update_price(drag_obj: Node):
	if drag_obj == null or drag_obj.from_shop:
		price_label.text = "--"
		holding_sellable = false
		set_box_scale(c_normal_size)
		return
	price_label.text = str(drag_obj.sell_price)
	holding_sellable = true


func _on_panel_container_mouse_entered() -> void:
	GameState.drag_sell_button = true
	if holding_sellable:
		set_box_scale(c_wombo_size)


func _on_panel_container_mouse_exited() -> void:
	GameState.drag_sell_button = false
	if holding_sellable:
		set_box_scale(c_normal_size)
	
func set_box_scale(val: float):
	if box.scale.x != val:
		box.scale = Vector2(val, val)
