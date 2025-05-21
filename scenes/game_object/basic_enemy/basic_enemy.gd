extends CharacterBody2D

const MAX_SPEED = 75
const ACCELERATION = 400
const FRICTION = 600

signal claw_attack(position: Vector2)

@onready var visuals = $Visuals
@onready var velocity_component = $VelocityComponent
@onready var name_label: Label = $NameLabel
@onready var health_bar: ProgressBar = $HealthBar
@onready var health_component: HealthComponent = $HealthComponent
@onready var attack_distance: Area2D = $AttackDistance
@onready var claw_cd: Timer = %ClawCD
@onready var attack_animation_player: AnimationPlayer = $AttackAnimationPlayer
@onready var death_component: Node2D = $DeathComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var claw_ability_controller: Node = $ClawAbilityController
@onready var drop_component: Node = $DropComponent

@export var enemy_name: String = "敌人"

var enemy_info: EnemyTemplate
var is_moving: bool = true
var is_stop_moving: bool = false


func _ready() -> void:
	health_component.health_changed.connect(_on_health_changed)
	$HurtboxComponent.hit.connect(on_hit)
	enemy_info = EnemyTemplate.create_normal_enemy()
	enemy_info.enemy_name = enemy_name
	attack_distance.area_entered.connect(_on_attack_distance_area_entered)
	attack_distance.area_exited.connect(_on_attack_distance_area_exited)
	claw_cd.timeout.connect(_on_claw_cd_timeout)
	update_attributes()


func set_level(level: int):
	enemy_info.setup_scaled_enemy(level)
	update_attributes()


func update_attributes() -> void:
	name_label.text = enemy_info.enemy_name + " Lv." + str(enemy_info.level)
	health_component.max_health = enemy_info.base_health
	health_component.current_health = enemy_info.base_health
	update_health_display()
	death_component.experience_drop = enemy_info.base_exp
	hurtbox_component.defense = enemy_info.base_defense
	claw_ability_controller.basic_damage = enemy_info.base_attack
	drop_component.level = enemy_info.level
	health_bar.value = 1


func _process(delta: float) -> void:
	velocity_component.accelerate_to_player(is_moving)
	velocity_component.move(self)
	
	var player = get_tree().get_first_node_in_group("player")
	var direction = (player.global_position - global_position).normalized()
	var move_sign = sign(direction.x)
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1)


func get_direction_to_player():
	var player_node = get_tree().get_first_node_in_group("player") as Node2D
	if player_node != null:
		return (player_node.global_position - global_position).normalized()
	return Vector2.ZERO


func on_hit():
	$HitRandomAudioPlayer2DComponent.play_random()


func update_health_display():
	health_bar.value = health_component.get_health_percent()


func _on_health_changed():
	update_health_display()


func _on_attack_distance_area_entered(other_area: Area2D):
	is_stop_moving = true
	is_moving = false
	$AnimationPlayer.play("RESET")
	await $AnimationPlayer.animation_finished
	await get_tree().create_timer(.4).timeout
	_on_claw_cd_timeout()
	claw_cd.start()


func _on_attack_distance_area_exited(other_area: Area2D):
	is_stop_moving = false
	is_moving = true
	claw_cd.stop()


func _on_claw_cd_timeout():
	attack_animation_player.play("attack")
	await attack_animation_player.animation_finished
	var player =  get_tree().get_first_node_in_group("player") as Node2D
	if player != null:
		claw_attack.emit(player.global_position)
	
	
