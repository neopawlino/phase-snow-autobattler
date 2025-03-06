extends Node2D


@export var follow_target : Node2D

@export var visual_follow_speed : float = 30


signal death_anim_finished

var death_anim_playing : bool
var velocity : Vector2

const OOB_MARGIN : float = 50.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if death_anim_playing:
		self.global_position += velocity * delta
		var gravity_vector : Vector2 = ProjectSettings.get_setting("physics/2d/default_gravity_vector")
		var gravity_magnitude : int = ProjectSettings.get_setting("physics/2d/default_gravity")
		velocity += gravity_vector * gravity_magnitude * delta
		if self.is_oob():
			death_anim_finished.emit()
	else:
		var offset := follow_target.global_position - self.global_position
		self.global_position += offset * visual_follow_speed * delta


func play_death_anim(force_x : float) -> void:
	death_anim_playing = true
	const Y_VEL_MULT : float = -2.0
	var y_vel := absf(force_x) * Y_VEL_MULT
	velocity = Vector2(force_x, y_vel)


func is_oob():
	var viewport_size := get_viewport_rect().size
	return self.global_position.x < 0.0 - OOB_MARGIN or self.global_position.x > viewport_size.x + OOB_MARGIN \
		or self.global_position.y < 0.0 - OOB_MARGIN or self.global_position.y > viewport_size.y + OOB_MARGIN
