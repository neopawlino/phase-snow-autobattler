extends Node2D


@export var follow_target : Node2D

@export var visual_follow_speed : float = 30


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var offset := follow_target.global_position - self.global_position
	self.global_position += offset * visual_follow_speed * delta
