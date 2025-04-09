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
@export var stat_changes : Array[StatValue]
@export var scaling : Array[StatValue]

@export var trigger : Trigger
@export var cooldown : float = 1.0
@export var cast_chance : float = 1.0

@export var has_unique_description_logic : bool
@export var ability_id : StringName
@export var ability_data : Dictionary


func get_format_string_values():
	var values : Array = []
	for stat_change in stat_changes:
		values.append(stat_change.amount + calc_stat_scaling_amount())
	return values


func calc_stat_scaling_amount() -> float:
	var amt : float = 0
	for stat_val in self.scaling:
		match stat_val.stat:
			StatValue.Stat.VIEWS:
				amt += GameState.stream_manager.views * stat_val.amount
			StatValue.Stat.VIEWS_PER_SEC:
				amt += GameState.stream_manager.views_per_sec * stat_val.amount
			StatValue.Stat.VIEWER_RETENTION:
				amt += GameState.stream_manager.viewer_retention * stat_val.amount
			StatValue.Stat.VIEWERS:
				amt += GameState.stream_manager.viewers * stat_val.amount
			StatValue.Stat.SUBSCRIBER_RATE:
				amt += GameState.stream_manager.subscriber_rate * stat_val.amount
			StatValue.Stat.SUBSCRIBERS:
				amt += GameState.subscribers * stat_val.amount
			StatValue.Stat.MEMBER_RATE:
				amt += GameState.stream_manager.member_rate * stat_val.amount
			StatValue.Stat.MEMBERS:
				amt += GameState.members * stat_val.amount
			_:
				print_debug("Unsupported stat: %s" % stat_val.stat)
	return amt


func get_description() -> String:
	if self.has_unique_description_logic:
		return self.get_unique_description()
	if self.scaling.is_empty():
		return self.description
	return self.description % self.get_format_string_values()


func get_unique_description() -> String:
	match self.ability_id:
		&"energy_drink":
			return self.description % max(self.ability_data.get('heal_amount', 0), 0)
	return self.description
