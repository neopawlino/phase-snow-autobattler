extends Control


@onready var price_label : Label = %PriceLabel


func _ready() -> void:
	GameState.drag_char_changed.connect(update_price)


func update_price(char: Character):
	if char == null or char.from_shop:
		price_label.text = "--"
		return
	price_label.text = str(char.sell_price)


func _on_panel_container_mouse_entered() -> void:
	GameState.drag_sell_button = true


func _on_panel_container_mouse_exited() -> void:
	GameState.drag_sell_button = false
