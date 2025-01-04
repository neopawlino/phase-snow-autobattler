extends Node

signal ability_applied(ability : AbilityLevel, team : int, targets : Array[int])
signal character_tooltip_opened


func close_all_tooltips():
	character_tooltip_opened.emit()
