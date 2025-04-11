extends Node

static var stat_names : Dictionary[StatValue.Stat, String] = {
	StatValue.Stat.VIEWS: "Views",
	StatValue.Stat.VIEWS_PER_SEC: "Views/sec",
	StatValue.Stat.VIEWER_RETENTION: "Viewer Retention",
	StatValue.Stat.VIEWERS: "Viewers",
	StatValue.Stat.SUBSCRIBER_RATE: "Subscription Rate",
	StatValue.Stat.SUBSCRIBERS: "Subscribers",
	StatValue.Stat.MEMBER_RATE: "Membership Rate",
	StatValue.Stat.MEMBERS: "Members",
	StatValue.Stat.STAMINA: "Stamina",
}

func get_stat_change_string(stat_value : StatValue) -> String:
	if stat_value.stat == StatValue.Stat.MONEY:
		return format_money(stat_value.amount, true)
	var percent := "%%" if is_percent(stat_value.stat) else ""
	var format_string := "%s" + percent + " %s"
	return format_string % [format_stat_number(stat_value, true), stat_names.get(stat_value.stat, "???")]


func format_stat_number(stat_value : StatValue, show_plus : bool = false) -> String:
	if is_percent(stat_value.stat):
		if show_plus:
			return "%+d" % (stat_value.amount * 100)
		else:
			return "%d" % (stat_value.amount * 100)
	return format_number(stat_value.amount, show_plus)


func format_number(num : float, show_plus : bool = false) -> String:
	if num >= 1e15: # switch to scientific at quadrillion
		return format_scientific(num, show_plus)
	elif num >= 1e12: # 1 trillion
		return format_letters(num, 1e12, "T", show_plus)
	elif num >= 1e9: # billion
		return format_letters(num, 1e9, "B", show_plus)
	elif num >= 1e6: # million
		return format_letters(num, 1e6, "M", show_plus)
	elif num >= 1e3: # thousand
		return format_letters(num, 1e3, "K", show_plus)
	else:
		if show_plus:
			return "%+d" % num
		return "%d" % num


func format_letters(num : float, letter_value : float, letter : String, show_plus : bool = false) -> String:
	var significand := num / letter_value
	var format_string := "%"
	if show_plus:
		format_string += "+"
	if significand >= 100:
		format_string += "d%s"
		return format_string % [significand, letter]
	elif significand >= 10:
		significand *= 10
		significand = floorf(significand)
		significand /= 10
		format_string += ".1f%s"
		return format_string % [significand, letter]
	else:
		significand *= 100
		significand = floorf(significand)
		significand /= 100
		format_string += ".2f%s"
		return format_string % [significand, letter]


func format_scientific(num : float, show_plus : bool = false) -> String:
	var exponent := log(num) / log(10.0)
	var significand := num / pow(10, floorf(exponent) - 2) # to hundreds place
	significand = floorf(significand) # always round down
	significand /= 100.0 # back to ones place
	if show_plus:
		return "%+.2fe%d" % [significand, exponent]
	return "%.2fe%d" % [significand, exponent]


func is_percent(stat : StatValue.Stat):
	return stat in [
		StatValue.Stat.VIEWER_RETENTION,
		StatValue.Stat.SUBSCRIBER_RATE,
		StatValue.Stat.MEMBER_RATE,
	]


func format_money(value : float, show_plus : bool = false) -> String:
	var plus_or_minus := ""
	if value > 0 and show_plus:
		plus_or_minus = "+"
	if value < 0:
		plus_or_minus = "-"
	if absf(value) >= 1e6:
		return plus_or_minus + "$" + format_number(absf(value), false)
	else:
		return plus_or_minus + "$%.2f" % absf(value)
