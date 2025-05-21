extends Node
class_name GlobalConstant

const ATTRIBUTES_WEIGHT_TABLE: Dictionary[String, float] = {
	"生命值": 0.2,
	"攻击力": 1.0,
	"防御力": 0.3,
	"每秒回复": 1.0,
}

enum DROP_ENUM {
	BLUE_VIAL,
	SWORD,
	CHEST,
	SHOE,
	HEAD,
	RING,
	NECKLACE,
	ELIXIR,
}

const DROP_MAPPER = [
	'blue_vial',
	'sword',
	'chest',
	'shoe',
	'head',
	'ring',
	'necklace',
	'elixir',
]
