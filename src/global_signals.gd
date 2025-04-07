extends Node


signal ability_applied(ability : AbilityDefinition, caster_statuses : Dictionary)
signal character_tooltip_opened(char : Character)

signal character_died(char : Character)
signal player_character_died(char : Character)


signal stream_anim_started

signal stream_started
signal stream_ended(result: StreamSummary.StreamResult, money: int, income: int, hp_gain: int)
signal stream_results_confirmed
signal stream_end_anim_finished

signal rewards_screen_finished
