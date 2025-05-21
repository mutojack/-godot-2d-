extends Node

const MAX_RANGE = 150

@export var claw_ability: PackedScene
@export var target: GlobalEnum.TARGET_TYPE = GlobalEnum.TARGET_TYPE.PLAYER

@export var basic_damage = 5
var base_wait_time
var start_position: Vector2


func _ready() -> void:
	if !owner.claw_attack:
		return
	owner.claw_attack.connect(_on_claw_attack)
	


func generate_claw():
	var claw_instance = claw_ability.instantiate() as ClawAbility
	if start_position:
		claw_instance.global_position = start_position
		
		var foreground = get_tree().get_first_node_in_group("foreground_layer") as Node2D
		if foreground == null:
			return
		foreground.add_child(claw_instance)
		claw_instance.hitbox_component.damage = basic_damage


func _on_claw_attack(position: Vector2):
	start_position = position
	generate_claw()
	
	
