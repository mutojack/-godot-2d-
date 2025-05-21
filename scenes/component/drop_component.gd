extends Node

@export var health_component: Node
@export var drop_table: Dictionary[GlobalConstant.DROP_ENUM, int]
@export var drop_percent: float
@export var level: int = 1
var weighted_table = WeightedTable.new()

func _ready() -> void:
	(health_component as HealthComponent).died.connect(on_died)
	fill_weighted_table()


func fill_weighted_table():
	for key in drop_table:
		var key_str = GlobalConstant.DROP_MAPPER[key]
		if key_str.contains("+"):
			var items = []
			var keys = key_str.split("+")
			for key_i in keys:
				var item = ResourceManager.get_item(key_i)
				if item:
					items.append(item)
			weighted_table.add_item(items, drop_table[key])
			return
		var item = ResourceManager.get_item(key_str)
		if item:
			weighted_table.add_item(item, drop_table[key])


func generate_scene(item):
	if !item or !item.scene_path or not owner is Node2D:
		return
	
	var drop_scene = load(item.scene_path)
	if drop_scene == null:
		return
	
	var spawn_position = (owner as Node2D).global_position
	var drop_instance = drop_scene.instantiate() as Node2D
	
	if item is EquipDrop:
		drop_instance.level = level
		if owner:
			var rarity = owner.enemy_info.get_random_rarity()
			drop_instance.rarity = rarity
	
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	entities_layer.add_child(drop_instance)
	
	# 初始位置设为敌人位置（局部坐标归零）
	drop_instance.global_position = spawn_position
	
	# === 关键修复 1：必须确保 Tween 绑定到场景树 ===
	var tween = create_tween().bind_node(drop_instance)  # 绑定到掉落物节点
	
	# === 随机参数 ===
	var rng = RandomNumberGenerator.new()
	rng.randomize()  # 确保每次随机不同
	
	var direction = Vector2.RIGHT.rotated(rng.randf_range(0, TAU))  # 随机方向
	var distance = rng.randf_range(30.0, 80.0)  # 掉落距离
	var peak_height = rng.randf_range(20.0, 40.0)  # 抛物线高度
	
	# 1. 上升阶段（0.2秒）
	tween.tween_property(drop_instance, "position:y", 
		-peak_height, 
		0.2).as_relative()  # 相对当前位置上升
	
	# 2. 水平移动 + 下落（0.4秒）
	tween.parallel().tween_property(drop_instance, "position:x",
		direction.x * distance,
		0.4).as_relative()  # 相对水平移动
	tween.parallel().tween_property(drop_instance, "position:y",
		peak_height, 
		0.4).as_relative().set_delay(0.2)  # 延迟下落
	
	# 旋转动画 
	drop_instance.rotation = rng.randf_range(-PI, PI)
	tween.parallel().tween_property(drop_instance, "rotation",
		rng.randf_range(-2.0, 2.0),
		0.6).as_relative()
	
	# 弹跳动画
	tween.chain().tween_property(drop_instance, "position:y", 
		-10.0, 
		0.1).as_relative().set_ease(Tween.EASE_OUT)
	tween.tween_property(drop_instance, "position:y",
		5.0,
		0.1).as_relative().set_ease(Tween.EASE_IN)


func on_died():
	if randf() > drop_percent:
		return
	
	var items = weighted_table.pick_item()
	if items is Array:
		for item in items:
			generate_scene(item)
	else:
		generate_scene(items)
