extends Node2D
class_name ClawAbility

@onready var hitbox_component: HitboxComponent = $Visuals/HitboxComponent


func _process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player != null:
		global_position = player.global_position
