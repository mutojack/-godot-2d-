extends Node
class_name HealthComponent

signal died
signal health_changed
signal player_health_changed(current: int, target: int)

@export var max_health: float = 10
@export var is_player: bool = false

@onready var sprite: Node2D = $"../Visuals"
@onready var collision_shape: CollisionShape2D = $"../CollisionShape2D"
@onready var hurt_shape_2d: CollisionShape2D = %HurtShape2D

var current_health
var init_position

func _ready() -> void:
	current_health = max_health


func damage(damage_amount: float):
	current_health = max(current_health - damage_amount, 0)
	health_changed.emit()
	if is_player:
		player_health_changed.emit(current_health, max_health)
	Callable(check_death).call_deferred()
	

func get_health_percent():
	if max_health <= 0:
		return 0
	
	return min(current_health / max_health, 1)

func check_death():
	if current_health <= 0:
		current_health = 0
		died.emit()
		if is_player:
			clear_enemies()
			if owner:
				owner.set_option_enabled(false)
			play_death_animation()  # 播放死亡动画
			await get_tree().create_timer(1.0).timeout # 等待动画完成
			respawn_player()
			if owner:
				owner.set_option_enabled(true)
		elif owner:
			owner.queue_free()


func play_death_animation():
	# 禁用碰撞
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	
	if hurt_shape_2d:
		hurt_shape_2d.set_deferred("disabled", true)
	
	# 创建Tween动画
	var tween = create_tween().set_parallel(true)
	
	# 倒地动画（旋转）
	tween.tween_property(sprite, "rotation", deg_to_rad(90), 0.3)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_BACK)
	
	# 淡出效果
	tween.tween_property(sprite, "modulate:a", 0.0, 0.8)\
		.set_ease(Tween.EASE_OUT)
	
	# 下沉效果
	tween.tween_property(sprite, "position:y", sprite.position.y + 20, 0.8)\
		.set_ease(Tween.EASE_IN)

func respawn_player():
	if owner is CharacterBody2D:
		# 重置位置和状态
		owner.global_position = init_position # 初始位置
		owner.velocity = Vector2.ZERO
		current_health = max_health
		health_changed.emit()
		player_health_changed.emit(current_health, max_health)
		
		# 重置精灵状态
		sprite.rotation = 0
		sprite.modulate.a = 1.0
		sprite.position.y = 0
		
		# 重新启用碰撞
		if collision_shape:
			collision_shape.disabled = false
		
		if hurt_shape_2d:
			hurt_shape_2d.disabled = false


func clear_enemies():
	for enemy in get_tree().get_nodes_in_group("enemy"):
		# 为每个敌人播放死亡动画
		if enemy.has_method("play_death_animation"):
			enemy.play_death_animation()
		else:
			# 默认淡出效果
			var tween = create_tween()
			tween.tween_property(enemy, "modulate:a", 0.0, 0.5)
			tween.tween_callback(enemy.queue_free)
