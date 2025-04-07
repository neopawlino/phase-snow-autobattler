extends Sprite2D

class_name CharacterSprite


const FLASH_DURATION : float = 0.3

var damage_shake_timer : int = 0
var damage_shake_amount_x : float = 7
var damage_shake_amount_y : float = 3


func _physics_process(delta: float) -> void:
	if damage_shake_timer <= 0:
		self.position = Vector2.ZERO
	else:
		self.position.x = damage_shake_amount_x * randf()
		self.position.y = damage_shake_amount_y * randf()
		damage_shake_timer -= 1


func damage_flash():
	var tween := get_tree().create_tween()
	tween.tween_method(set_shader_flash_intensity, 0.8, 0.0, FLASH_DURATION).set_trans(Tween.TRANS_SINE)


func set_shader_flash_intensity(value : float):
	var shader : ShaderMaterial = self.material
	shader.set_shader_parameter(&"flash_intensity", value)


func damage_shake(num_frames : int):
	damage_shake_timer = max(damage_shake_timer, num_frames)
