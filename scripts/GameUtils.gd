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
