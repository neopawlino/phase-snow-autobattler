extends Sprite2D

@export var char : Character

func _ready() -> void:
	GameState.drag_object_changed.connect(update_visibility)
	update_visibility(GameState.drag_object)


func update_visibility(drag_obj : Node):
	if drag_obj is Character:
		self.visible = char.can_merge(drag_obj)
	else:
		self.hide()
