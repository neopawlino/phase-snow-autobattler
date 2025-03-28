extends Node


signal ability_applied(ability : AbilityLevel, team : int, targets : Array[int], caster_statuses : Dictionary)
signal character_tooltip_opened(char : Character)

signal character_died(char : Character)
signal player_character_died(char : Character)


signal stream_anim_started
signal rewards_screen_finished
