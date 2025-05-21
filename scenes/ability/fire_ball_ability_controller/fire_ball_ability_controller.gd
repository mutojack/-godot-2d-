extends Node

const MAX_RANGE = 150

@export var fire_ball_ability: PackedScene
@export var target: GlobalEnum.TARGET_TYPE = GlobalEnum.TARGET_TYPE.PLAYER
@export var effect_type: GlobalEnum.EFFECT_TYPE = GlobalEnum.EFFECT_TYPE.BASE

@export var basic_damage = 5
var base_wait_time
var start_position: Vector2

@onready var fire_ball_timer: Timer = $FireBallTimer


func _ready() -> void:
	base_wait_time = fire_ball_timer.wait_time
	if !owner.remote_attack:
		return
	owner.remote_attack.connect(_on_remote_attack)
	


func generate_fire_ball():
	var fire_ball_instance = fire_ball_ability.instantiate() as FireBallAbility
	if start_position:
		fire_ball_instance.global_position = start_position
		# 设置火球方向
		var direction: Vector2
		match target:
			GlobalEnum.TARGET_TYPE.PLAYER:
				var player = get_tree().get_first_node_in_group("player")
				if player:
					direction = (player.global_position - start_position).normalized()
					
			GlobalEnum.TARGET_TYPE.ENEMY:
				var nearest_enemy = find_nearest_enemy()
				if nearest_enemy:
					direction = (nearest_enemy.global_position - start_position).normalized()
		
		# 如果找到有效目标则设置移动方向
		if direction != Vector2.ZERO:
			fire_ball_instance.set_direction(direction)  # 假设火球脚本有这个方法
			var foreground = get_tree().get_first_node_in_group("foreground_layer") as Node2D
			if foreground == null:
				return
			foreground.add_child(fire_ball_instance)
			fire_ball_instance.hitbox_component.damage = basic_damage
			await fire_ball_instance.ready
			# 设置火球是否穿透
			fire_ball_instance.hitbox_component.effect_type = effect_type

# 查找最近的敌人
func find_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.size() == 0:
		return null
	
	var nearest_enemy: Node2D = null
	var min_distance = INF
	
	for enemy in enemies:
		var distance = start_position.distance_to(enemy.global_position)
		if distance < min_distance and distance <= MAX_RANGE:
			min_distance = distance
			nearest_enemy = enemy
	
	return nearest_enemy


func _on_remote_attack(position: Vector2):
	start_position = position
	generate_fire_ball()
	
	
