extends Control

class_name CombatSummary

signal continue_button_pressed

enum CombatResult {
	WIN,
	LOSE,
	DRAW
}

@onready var interest_container : Container = %InterestContainer
@onready var interest_label : Label = %InterestLabel
@onready var reward_container : Container = %RewardContainer
@onready var reward_label : Label = %RewardLabel
@onready var damage_container : Container = %DamageContainer
@onready var damage_label : Label = %DamageLabel
@onready var income_container : Container = %IncomeContainer
@onready var income_label : Label = %IncomeLabel
@onready var interest_info : Label = %InterestInfo

@onready var title : Label = %TitleLabel


func _ready() -> void:
	GlobalSignals.stream_ended.connect(show_combat_summary)


func show_combat_summary(result: CombatResult, money: int, income: int = 0, hp_gain: int = 0):
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
	damage_container.visible = hp_gain != 0
	income_container.visible = income != 0
	reward_label.text = str(money)
	interest_label.text = str(interest)
	damage_label.text = str(hp_gain)
	income_label.text = str(income)
	interest_info.text = "1 per 5, max %s)" % GameState.get_interest_cap()
	self.show()


func _on_button_pressed() -> void:
	GlobalSignals.stream_results_confirmed.emit()
	self.hide()
