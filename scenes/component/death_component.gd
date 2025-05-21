extends Node2D

@export var health_component: Node
@export var sprite: Sprite2D
var experience_drop = 0


func _ready() -> void:
	$GPUParticles2D.texture = sprite.texture
	health_component.died.connect(on_died)


func on_died():
	if owner == null || not owner is Node2D:
		return
	
	GameEvents.emit_experience_vial_collected(experience_drop)
	var spawn_position = owner.global_position
	var entities = get_tree().get_first_node_in_group("entities_layer")
	self.reparent(entities)
	
	global_position = spawn_position
	$AnimationPlayer.play("default")
	$HitRandomAudioPlayer2DComponent.play_random()
	
