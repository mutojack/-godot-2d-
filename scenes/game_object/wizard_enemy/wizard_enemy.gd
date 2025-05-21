extends CharacterBody2D

signal remote_attack(start_position: Vector2)

@onready var velocity_component = $VelocityComponent
@onready var visuals = $Visuals
@onready var remote_attack_distance_component: Area2D = $RemoteAttackDistanceComponent
@onready var fire_ball_timer: Timer = $FireBallAbilityController/FireBallTimer
@onready var name_label: Label = $NameLabel
@onready var health_bar: ProgressBar = $HealthBar
@onready var health_component: HealthComponent = $HealthComponent
@onready var attack_animation_player: AnimationPlayer = $AttackAnimationPlayer
@onready var death_component: Node2D = $DeathComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var fire_ball_ability_controller: Node = $FireBallAbilityController
@onready var drop_component: Node = $DropComponent

@export var enemy_name: String = "敌人"

var enemy_info: EnemyTemplate
var is_moving = false
var is_stop_moving = false
var level: int = 1


func _ready() -> void:
	hurtbox_component.hit.connect(on_hit)
	remote_attack_distance_component.area_entered.connect(_on_remote_attack_distance_component_entered)
	remote_attack_distance_component.area_exited.connect(_on_remote_attack_distance_component_exited)
	health_component.health_changed.connect(_on_health_changed)
	fire_ball_timer.timeout.connect(_on_fire_ball_timer_timeout)
	enemy_info = EnemyTemplate.create_normal_enemy(level)
	enemy_info.enemy_name = enemy_name
	update_attributes()


func _process(delta: float) -> void:
	velocity_component.accelerate_to_player(is_moving)
	velocity_component.move(self)
	
	var player = get_tree().get_first_node_in_group("player")
	var direction = (player.global_position - global_position).normalized()
	var move_sign = sign(direction.x)
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1)


func update_attributes() -> void:
	name_label.text = enemy_info.enemy_name + " Lv." + str(enemy_info.level)
	health_component.max_health = enemy_info.base_health
	health_component.current_health = enemy_info.base_health
	update_health_display()
	death_component.experience_drop = enemy_info.base_exp
	hurtbox_component.defense = enemy_info.base_defense
	fire_ball_ability_controller.basic_damage = enemy_info.base_attack
	drop_component.level = enemy_info.level
	health_bar.value = 1


func set_is_moving(moving: bool):
	if is_stop_moving:
		is_moving = false
		return
	is_moving = moving


func update_health_display():
	health_bar.value = health_component.get_health_percent()
	

func on_hit():
	$HitRandomAudioPlayer2DComponent.play_random()


func _on_remote_attack_distance_component_entered(other_area: Area2D):
	is_stop_moving = true
	set_is_moving(false)
	$AnimationPlayer.play("RESET")
	await $AnimationPlayer.animation_finished
	await get_tree().create_timer(.4).timeout
	_on_fire_ball_timer_timeout()
	
	if fire_ball_timer.is_stopped():
		fire_ball_timer.start()


func _on_remote_attack_distance_component_exited(other_area: Area2D):
	is_stop_moving = false
	set_is_moving(true)
	$AnimationPlayer.play("walk")


func _on_fire_ball_timer_timeout():
	attack_animation_player.play("remote_attack")
	await attack_animation_player.animation_finished
	remote_attack.emit($Visuals/Weapon/Marker2D.global_position)
	if is_stop_moving:
		fire_ball_timer.start()


func _on_health_changed():
	update_health_display()
