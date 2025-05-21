extends Node

signal notify_experience_manager(experience: int)
signal item_quantity_removed(item: BasicDrop)


func _ready() -> void:
	GameEvents.use_consumable.connect(_on_use_consumable)	

# GameUtils.gd (Autoload) 获取敌人碰撞体半径（统一命名CollisionShape2D）
static func get_collision_radius(node: Node2D) -> float:
	var shape = node.find_child("CollisionShape2D", false) as CollisionShape2D
	if shape && shape.shape is CircleShape2D:
		return shape.shape.radius
	return 0.0  # 默认值或报错

#	计算伤害采用rpg经典模型
func calculate_damage(attack: int, defense: int, 
					 power: float = 1.0, randomness: float = 0.1) -> int:
	# power: 技能威力系数
	# randomness: 随机浮动范围(0.1=±10%)
	var base = (attack * 2.5 - defense * 1.5) * power
	var damage = base * randf_range(1.0 - randomness, 1.0 + randomness)
	return int(max(1, damage))


#  计算两个日期的时间差（秒数 + hh:mm:ss格式）
func calculate_time_diff(start_date: Dictionary, end_date: Dictionary) -> Dictionary:
	var start_unix = Time.get_unix_time_from_datetime_dict(start_date)
	var end_unix = Time.get_unix_time_from_datetime_dict(end_date)
	
	var diff_seconds = int(end_unix - start_unix)
	
	var diff_formatted = seconds_to_hhmmss(diff_seconds)
	
	return {
		"total_seconds": diff_seconds,
		"hhmmss": diff_formatted
	}

#秒数转hh:mm:ss
func seconds_to_hhmmss(total_seconds: int) -> String:
	var hours = total_seconds / 3600
	var minutes = (total_seconds % 3600) / 60
	var seconds = total_seconds % 60
	return "%02d时%02d分%02d秒" % [hours, minutes, seconds]

# 计算离线经验
func calc_outline_experience(total_seconds: int) -> int:
	var n_enemy = EnemyTemplate.create_normal_enemy(Global.player_info.level)
	n_enemy.setup_scaled_enemy()
	return int(total_seconds * 0.05 * n_enemy.base_exp) 


# mapper专门处理所有消耗物品的效果
func _on_use_consumable(item: BasicDrop):
	if item.type != BasicDrop.TYPE_ENUM.CONSUMABLE:
		return
	match item.id:
		'elixir':
			item.quantity -= 1				
			emit_notify_experience_manager(1000)
			if item.quantity <= 0:
				emit_item_quantity_removed(item)


func emit_notify_experience_manager(exp: int):
	notify_experience_manager.emit(exp)


func emit_item_quantity_removed(item: BasicDrop):
	item_quantity_removed.emit(item)
