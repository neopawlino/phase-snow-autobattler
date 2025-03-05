extends Sprite2D

class_name CharacterSprite


const FLASH_DURATION : float = 0.5


func damage_flash():
	var tween := get_tree().create_tween()
	tween.tween_method(set_shader_flash_intensity, 1.0, 0.0, FLASH_DURATION)


func set_shader_flash_intensity(value : float):
	var shader : ShaderMaterial = self.material
	shader.set_shader_parameter(&"flash_intensity", value)
