extends Node

@export var default_volume_value : float = 0.1

@export var audio_bus_name := "Master"
@onready var _bus := AudioServer.get_bus_index(audio_bus_name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioServer.set_bus_volume_db(_bus, linear_to_db(default_volume_value))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
