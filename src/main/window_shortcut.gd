extends Button

@export var window : CustomWindow
@export var notification_icon : Control

@export var click_sound : AudioStream

var default_size : Vector2
var default_pos : Vector2


func _ready() -> void:
	self.pressed.connect(on_pressed)
	self.default_size = window.size
	self.default_pos = window.position
	self.window.notification.connect(notification_icon.show)
	self.window.focus_entered.connect(notification_icon.hide)


func on_pressed():
	if not window.visible:
		window.size = self.default_size
		window.position = self.default_pos
		window.visible = true
	if click_sound:
		SoundManager.play_sound(click_sound)
	window.grab_focus()
