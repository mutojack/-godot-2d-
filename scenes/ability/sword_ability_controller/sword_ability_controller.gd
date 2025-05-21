extends Node

const MAX_RANGE = 150

@export var sword_ability: PackedScene
var basic_damage = 0
var base_wait_time

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_wait_time = $Timer.wait_time
	$Timer.timeout.connect(on_timer_timeout)
	#GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if !player: return
	
	# 获取并过滤敌人
	var enemies = get_tree().get_nodes_in_group("enemy")
	enemies = enemies.filter(func(enemy: Node2D):
		return enemy.global_position.distance_squared_to(player.global_position) < pow(MAX_RANGE, 2)
	)
	
	if enemies.size() == 0: return
	
	# 稳定排序
	enemies.sort_custom(func(a, b):
		return a.global_position.distance_squared_to(player.global_position) < b.global_position.distance_squared_to(player.global_position)
	)
	
	# 锁定目标
	var nearest_enemy = enemies[0]
	if !is_instance_valid(nearest_enemy): return
	
	# 生成剑（添加边缘偏移）
	var sword_instance = sword_ability.instantiate() as Node2D
	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
	foreground_layer.add_child(sword_instance)
	sword_instance.hitbox_component.damage = basic_damage
	
	var attack_dir = (nearest_enemy.global_position - player.global_position).normalized()
	sword_instance.global_position = nearest_enemy.global_position - attack_dir * 20  # 边缘偏移
	
	# 确保朝向正确
	sword_instance.rotation = attack_dir.angle()


#func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	#if upgrade.id == "sword_rate":
		#var percent_reduction = current_upgrades["sword_rate"]["quantity"] * .1
		#$Timer.wait_time = base_wait_time * (1 - percent_reduction)
		#$Timer.start()
	#elif upgrade.id == "sword_damage":
		#additional_damage_percent = 1 + (current_upgrades["sword_damage"]["quantity"] * .15)
