class_name StatValue
extends Resource

enum Stat {
	VIEWS,
	VIEWS_PER_SEC,
	VIEWER_RETENTION,
	VIEWERS,
	SUBSCRIBER_RATE,
	SUBSCRIBERS,
	MEMBER_RATE,
	MEMBERS,
	STAMINA,
	MONEY,
}

@export var stat : Stat
@export var amount : float
