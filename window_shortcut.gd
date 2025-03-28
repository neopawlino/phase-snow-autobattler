extends Button

@export var window : Window

var default_size : Vector2
var default_pos : Vector2

func _ready() -> void:
	self.pressed.connect(on_pressed)
	self.default_size = window.size
	self.default_pos = window.position


func on_pressed():
	if not window.visible:
		window.size = self.default_size
		window.position = self.default_pos
		window.visible = true
