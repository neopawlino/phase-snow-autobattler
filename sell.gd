extends Control


@onready var price_label : Label = %PriceLabel


func _ready() -> void:
	GameState.drag_object_changed.connect(update_price)


func update_price(drag_obj: Node):
	if drag_obj == null or drag_obj.from_shop:
		price_label.text = "--"
		return
	price_label.text = str(drag_obj.sell_price)


func _on_panel_container_mouse_entered() -> void:
	GameState.drag_sell_button = true


func _on_panel_container_mouse_exited() -> void:
	GameState.drag_sell_button = false
