extends Node

const SPAWN_RADIUS = 375

@export var basic_enemy_scene: PackedScene
@export var wizard_enemy_scene: PackedScene
@export var arena_time_manager: Node
@export var max_spawn_count = 1

@onready var monster_setting_page: CanvasLayer = %MonsterSettingPage
@onready var timer = $Timer
@onready var experience_manager: Node = $"../Entities/Player/ExperienceManager"

var base_spawn_time = 0
var enemy_table = WeightedTable.new()
var is_gene_by_player = true
var min_level: int = 1
var max_level: int = 5


func _ready() -> void:
	enemy_table.add_item(basic_enemy_scene, 3000)
	enemy_table.add_item(wizard_enemy_scene, 1000)
	base_spawn_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)
	monster_setting_page.monster_level_range_selected.connect(on_monster_level_range_selected)
	monster_setting_page.monster_max_count_selected.connect(on_monseter_max_count_selected)
	if Global.player_info:
		var player_info = Global.player_info
		min_level = max(1, player_info.level - 1)
		max_level = max(1, player_info.level + 1)

func set_level_by_player():
	if Global.player_info:
		var player_info = Global.player_info
		min_level = max(1, player_info.level - 1)
		max_level = max(1, player_info.level + 1)


func get_spawn_position(enemy: Node2D):
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return Vector2.ZERO

	var spawn_position = Vector2.ZERO
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	
	for i in 8:
		spawn_position = player.global_position + (random_direction * SPAWN_RADIUS)
		
		# 检测玩家到生成点之间是否有障碍物
		var ray_params = PhysicsRayQueryParameters2D.create(
			player.global_position, 
			spawn_position, 
			1 << 0 
		)
		var ray_result = get_tree().root.world_2d.direct_space_state.intersect_ray(ray_params)
		if !ray_result.is_empty():
			random_direction = random_direction.rotated(deg_to_rad(45))
			continue
		
		# 检测生成点是否可放置敌人（圆形区域检测）
		if enemy == null:
			return

		var shape = CircleShape2D.new()
		shape.radius = GameUtils.get_collision_radius(enemy)
		var shape_params = PhysicsShapeQueryParameters2D.new()
		shape_params.shape = shape
		shape_params.transform = Transform2D(0, spawn_position)
		shape_params.collision_mask = 1 << 0
		
		var shape_result = get_tree().root.world_2d.direct_space_state.intersect_shape(shape_params)
		if shape_result.is_empty():
			return spawn_position  # 安全位置
		else:
			random_direction = random_direction.rotated(deg_to_rad(45))
	
	return Vector2.ZERO

func on_timer_timeout():
	if max_spawn_count != -1:
		var enemies = get_tree().get_nodes_in_group("enemy")
		if enemies.size() >= max_spawn_count:
			timer.start()
			return

	timer.start()
	
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	
	var enemy_scene = enemy_table.pick_item()
	var enemy = enemy_scene.instantiate() as Node2D
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	var random_level = randi_range(min_level, max_level)
	print("ac_min_max", " %d:%d " % [min_level, max_level], " random:", random_level)
	enemy.level = random_level
	entities_layer.add_child(enemy)
	enemy.global_position = get_spawn_position(enemy)


func on_arena_difficulty_increased(arena_difficulty: int):
	var time_off = (.1 / 12) * arena_difficulty
	time_off = min(time_off, .7)
	timer.wait_time = base_spawn_time - time_off


func on_monster_level_range_selected(min: int, max: int):
	if min == max and min == 0:
		set_level_by_player()
	else:
		min_level = min
		max_level = max
		is_gene_by_player = false


func on_monseter_max_count_selected(count: int):
	max_spawn_count = count
	
	
