extends Area2D
class_name HitboxComponent

@export var one_shot: bool = true
var damage = 5

@export var effect_type: GlobalEnum.EFFECT_TYPE = GlobalEnum.EFFECT_TYPE.PIERCE


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(other_area):
	if one_shot:
		if effect_type == GlobalEnum.EFFECT_TYPE.BASE:
			owner.queue_free()
