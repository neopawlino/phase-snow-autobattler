extends Node
class_name CustomTimer

var wait_time : float = 1.0
var time_left : float = 1.0
var speed_mult : float = 1.0
var started : bool

var progress_bar : ProgressBar

signal timeout

func _physics_process(delta: float) -> void:
	if not started:
		return
	time_left -= delta * speed_mult
	if time_left <= 0.0:
		timeout.emit()
		time_left += wait_time
	if progress_bar:
		progress_bar.min_value = 0.0
		progress_bar.max_value = wait_time
		progress_bar.value = time_left
