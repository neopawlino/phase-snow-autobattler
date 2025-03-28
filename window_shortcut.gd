extends Button

@export var window : Window

func _ready() -> void:
	self.pressed.connect(on_pressed)


func on_pressed():
	window.visible = true
