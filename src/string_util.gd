extends Node

static func format_number(num : float) -> String:
	if num >= 1e15: # switch to scientific at quadrillion
		return format_scientific(num)
	elif num >= 1e12: # 1 trillion
		return format_letters(num, 1e12, "T")
	elif num >= 1e9: # billion
		return format_letters(num, 1e9, "B")
	elif num >= 1e6: # million
		return format_letters(num, 1e6, "M")
	elif num >= 1e3: # thousand
		return format_letters(num, 1e3, "K")
	else:
		return "%d" % num


static func format_letters(num : float, letter_value : float, letter : String) -> String:
	var significand := num / letter_value
	if significand >= 100:
		return "%d%s" % [significand, letter]
	elif significand >= 10:
		significand *= 10
		significand = floorf(significand)
		significand /= 10
		return "%.1f%s" % [significand, letter]
	else:
		significand *= 100
		significand = floorf(significand)
		significand /= 100
		return "%.2f%s" % [significand, letter]


static func format_scientific(num : float) -> String:
	var exponent := log(num) / log(10.0)
	var significand := num / pow(10, floorf(exponent) - 2) # to hundreds place
	significand = floorf(significand) # always round down
	significand /= 100.0 # back to ones place
	return "%.2fe%d" % [significand, exponent]
