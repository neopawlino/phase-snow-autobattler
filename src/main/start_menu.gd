extends Control

@export var task_bar : Control

func _input(event: InputEvent) -> void:
	if not self.visible:
		return
	if event is InputEventMouseButton:
		var rect := self.get_global_rect()
		var taskbar_rect := task_bar.get_global_rect()
		if not rect.has_point(event.position) and not taskbar_rect.has_point(event.position):
			self.hide()
