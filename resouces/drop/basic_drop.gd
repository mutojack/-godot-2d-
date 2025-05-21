extends Resource
class_name BasicDrop

signal quantity_changed

enum TYPE_ENUM {
	NONE,
	EQUIPMENT,
	CONSUMABLE,
	MARTERIAL,
}

@export var id: String
@export var name: String
@export var type: TYPE_ENUM = TYPE_ENUM.NONE
@export_multiline var description: String
@export var max_stack: int = 1
@export var cd: int = -1
@export var quantity: int = 1:
	set(value):
		quantity_changed.emit(value)
		quantity = value
@export_file("*.tscn") var scene_path: String
@export var texture: Texture2D


func is_max_stack() -> bool:
	return quantity >= max_stack


func merge(item: BasicDrop) -> void:
	var old_quantity = quantity
	quantity = min(max_stack, quantity + item.quantity)
	item.quantity = max(0, item.quantity - (quantity - old_quantity))
