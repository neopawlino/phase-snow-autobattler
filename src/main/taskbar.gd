extends Control

var initial_position : Vector2

@export var settings_window : Window

@export var settings_button : Button
@export var quit_button : Button

@export var start_menu : Control

var settings_default_size
var settings_default_pos


func _ready() -> void:
	self.initial_position = self.global_position

	self.settings_default_size = settings_window.size
	self.settings_default_pos = settings_window.position

	GlobalSignals.stream_anim_started.connect(hide_anim)
	GlobalSignals.stream_results_confirmed.connect(show_anim)
	self.settings_button.pressed.connect(on_settings_button_pressed)

	# Hide quit button on web export
	self.quit_button.visible = not OS.has_feature("web")


func on_settings_button_pressed():
	if not settings_window.visible:
		settings_window.size = self.settings_default_size
		settings_window.position = self.settings_default_pos
		settings_window.visible = true
	settings_window.grab_focus()
	start_menu.hide()


func hide_anim():
	var tween := self.create_tween()
	var target_pos := self.initial_position
	target_pos.y += 500
	tween.tween_property(self, "global_position", target_pos, 1.0).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(self.hide)


func show_anim():
	self.show()
	var tween := self.create_tween()
	var target_pos := self.initial_position
	tween.tween_property(self, "global_position", target_pos, 1.0).set_trans(Tween.TRANS_QUAD)
