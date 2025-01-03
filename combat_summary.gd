extends Control

class_name CombatSummary

signal continue_button_pressed

enum CombatResult {
	WIN,
	LOSE,
	DRAW
}

@onready var interest_container : BoxContainer = %InterestContainer
@onready var interest_label : Label = %InterestLabel
@onready var reward_container : BoxContainer = %RewardContainer
@onready var reward_label : Label = %RewardLabel
@onready var title : Label = %TitleLabel


func show_combat_summary(result: CombatResult, money: int):
	var title_text : String
	match result:
		CombatResult.WIN:
			title_text = "Victory!"
		CombatResult.LOSE:
			title_text = "Defeat!"
		CombatResult.DRAW:
			title_text = "Draw!"
	title.text = title_text
	var interest := GameState.get_interest()
	interest_container.visible = interest != 0
	reward_container.visible = money != 0
	reward_label.text = str(money)
	interest_label.text = str(interest)
	visible = true


func _on_button_pressed() -> void:
	continue_button_pressed.emit()
