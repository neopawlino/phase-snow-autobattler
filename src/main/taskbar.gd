extends Control

var initial_position : Vector2


func _ready() -> void:
	self.initial_position = self.global_position
	GlobalSignals.stream_anim_started.connect(hide_anim)
	GlobalSignals.stream_results_confirmed.connect(show_anim)


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
