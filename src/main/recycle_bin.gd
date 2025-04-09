extends Control


func _ready() -> void:
	self.mouse_entered.connect(on_mouse_entered)
	self.mouse_exited.connect(on_mouse_exited)


func on_mouse_entered() -> void:
	GameState.drag_sell_button = true


func on_mouse_exited() -> void:
	GameState.drag_sell_button = false
