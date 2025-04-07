extends Resource

class_name StatusEffect

enum StatusId {
	STRENGTH,
	TOXIC,
	ARMOR,
	ENVENOM,
	ARMOR_BREAKER,
}

@export var status_id : StatusId
@export var value : int
