extends Resource

class_name AbilityDefinition

enum Trigger {
	COOLDOWN,
	STREAM_START,
	ABILITY_USED,
	SUBSCRIBER_GAINED,
}

@export var ability_name : String
@export var icon : Texture2D
@export_multiline var description : String
@export var ability_effects : Array[AbilityEffect]

@export var trigger : Trigger
@export var cooldown : float = 1.0

@export var cast_chance : float = 1.0

@export var has_unique_description_logic : bool
@export var ability_id : StringName
@export var ability_data : Dictionary


func get_format_string_values() -> Array:
	var values : Array = []
	for effect in ability_effects:
		if effect.stat_scaling:
			values.append(effect.stat_change.amount + calc_stat_scaling_amount(effect.stat_scaling))
	return values


static func calc_stat_scaling_amount(scaling : StatValue) -> float:
	var amt : float = 0
	match scaling.stat:
		StatValue.Stat.VIEWS:
			amt += GameState.stream_manager.views * scaling.amount
		StatValue.Stat.VIEWS_PER_SEC:
			amt += GameState.stream_manager.views_per_sec * scaling.amount
		StatValue.Stat.VIEWER_RETENTION:
			amt += GameState.stream_manager.viewer_retention * scaling.amount
		StatValue.Stat.VIEWERS:
			amt += GameState.stream_manager.viewers * scaling.amount
		StatValue.Stat.SUBSCRIBER_RATE:
			amt += GameState.stream_manager.subscriber_rate * scaling.amount
		StatValue.Stat.SUBSCRIBERS:
			amt += GameState.subscribers * scaling.amount
		StatValue.Stat.MEMBER_RATE:
			amt += GameState.stream_manager.member_rate * scaling.amount
		StatValue.Stat.MEMBERS:
			amt += GameState.members * scaling.amount
		StatValue.Stat.MONEY:
			amt += GameState.player_money * scaling.amount
		_:
			print_debug("Unsupported stat: %s" % scaling.stat)
	return amt


func get_description() -> String:
	if self.has_unique_description_logic:
		return self.get_unique_description()
	var scaling_values := self.get_format_string_values()
	if scaling_values.is_empty():
		return self.description
	return self.description % scaling_values


func get_unique_description() -> String:
	match self.ability_id:
		&"energy_drink":
			return self.description % max(self.ability_data.get('heal_amount', 0), 0)
	return self.description
