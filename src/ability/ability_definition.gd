extends Resource

class_name AbilityDefinition

@export var ability_name : String
@export var icon : Texture2D
@export_multiline var description : String
@export var stat_changes : Array[StatValue]

@export var cooldown : float = 1.0

@export var scaling : Array[StatValue]
@export var ability_keys : Array[StringName]


func get_format_string_values():
	#if len(stat_changes) == 1:
		#return stat_changes[0].amount + calc_stat_scaling_amount()
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
