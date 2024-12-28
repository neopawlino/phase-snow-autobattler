extends Node

var paused : bool = false:
	set(val):
		paused = val
		paused_changed.emit(val)
signal paused_changed(is_paused : bool)
