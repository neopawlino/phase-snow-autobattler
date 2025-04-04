extends Control

class_name StreamSummary

signal continue_button_pressed

enum StreamResult {
	WIN,
	LOSE,
	DRAW
}

@export var views_label : Label
@export var viewers_label : Label
@export var subscribers_label : Label
@export var members_label : Label

@export var overlay : CanvasItem

var orig_position : Vector2

func _ready() -> void:
	GlobalSignals.stream_ended.connect(show_combat_summary)
	orig_position = self.global_position


func show_combat_summary(result: StreamResult, money: int, income: int = 0, hp_gain: int = 0):
	#var title_text : String
	#match result:
		#StreamResult.WIN:
			#title_text = "Victory!"
		#StreamResult.LOSE:
			#title_text = "Defeat!"
		#StreamResult.DRAW:
			#title_text = "Draw!"
	#title.text = title_text
	#var interest := GameState.get_interest()
	#interest_container.visible = interest != 0
	#reward_container.visible = money != 0
	#damage_container.visible = hp_gain != 0
	#income_container.visible = income != 0
	#reward_label.text = str(money)
	#interest_label.text = str(interest)
	#damage_label.text = str(hp_gain)
	#income_label.text = str(income)
	#interest_info.text = "1 per 5, max %s)" % GameState.get_interest_cap()

	self.views_label.text = "%d" % GameState.stream_manager.views
	self.viewers_label.text = "%d" % GameState.stream_manager.peak_viewers
	self.subscribers_label.text = "%d" % GameState.stream_manager.new_subscribers
	self.members_label.text = "%d" % GameState.stream_manager.new_members

	self.show_anim()


func show_anim():
	self.overlay.modulate.a = 0
	var tween := self.create_tween()
	tween.tween_property(self.overlay, "modulate:a", 1.0, 0.5)
	self.global_position.y = orig_position.y + 1000
	tween.parallel().tween_property(self, "global_position:y", orig_position.y, 0.5).set_trans(Tween.TRANS_QUAD)
	self.show()


func _on_button_pressed() -> void:
	GlobalSignals.stream_results_confirmed.emit()
	self.hide_anim()


func hide_anim():
	var tween := self.create_tween()
	tween.tween_property(self.overlay, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(self, "global_position:y", orig_position.y + 1000, 0.5).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(self.hide)
