extends Node


signal ability_applied(ability : AbilityDefinition, caster_statuses : Dictionary)
signal character_tooltip_opened(char : Character)

signal character_died(char : Character)
signal player_character_died(char : Character)

signal show_damage_number(value: String, pos: Vector2, color : Color)


signal stream_anim_started

signal stream_started
signal stream_ended
signal stream_results_confirmed
signal stream_end_anim_finished

signal rewards_screen_finished
