extends Node

static func format_number(num : float) -> String:
	if num >= 1e15: # switch to scientific at quadrillion
		return format_scientific(num)
	elif num >= 1e12: # 1 trillion
		return "%.2fT" % (num / 1e12)
	elif num >= 1e9: # billion
		return "%.2fB" % (num / 1e9)
	elif num >= 1e6: # million
		return "%.2fM" % (num / 1e6)
	elif num >= 1e3: # thousand
		return "%.2fK" % (num / 1e3)
	else:
		return "%d" % num


static func format_scientific(num : float) -> String:
	var exponent := log(num) / log(10.0)
	var significand := num / floorf(exponent)
	return "%.2fe%d" % [significand, exponent]
