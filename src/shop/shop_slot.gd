extends Slot
class_name ShopSlot

@export var title_label : Label
@export var price_label : Label
@export var buy_button : Button

signal buy_button_pressed(slot : ShopSlot)

var default_text := "Buy Now"
var sold_out_text := "Sold Out"
var no_money_text := "Can't Afford"


var buy_price : float


func _ready() -> void:
	buy_button.pressed.connect(func():
		self.buy_button_pressed.emit(self)
	)


func set_title(text : String):
	self.title_label.text = text


func set_price(val : float):
	self.price_label.text = "$%.2f" % val
	self.buy_price = val


func set_sold_out(sold_out : bool):
	if sold_out:
		self.buy_button.text = self.sold_out_text
	else:
		self.buy_button.text = self.default_text
	self.buy_button.disabled = sold_out


func set_can_afford(can_afford : bool):
	if can_afford:
		self.buy_button.text = self.default_text
	else:
		self.buy_button.text = self.no_money_text
	self.buy_button.disabled = not can_afford
