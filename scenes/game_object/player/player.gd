extends CharacterBody2D
class_name PlayerScene
const MAX_SPEED = 125
const ACCELERATION_SMOOTHING = 25

@export var attack_range: float = 20.0  # 攻击触发距离
@export var auto_attack_cooldown: float = 1.0  # 自动攻击冷却时间

@onready var damage_interval_timer = $DamageIntervalTimer
@onready var health_component = $HealthComponent
@onready var health_bar = $HealthBar
@onready var abilities = $Abilities
@onready var animation_player = $AnimationPlayer
@onready var visuals = $Visuals
@onready var cd_common_timer: Timer = %CDCommonTimer
@onready var attack_animation_player: AnimationPlayer = %AttackAnimationPlayer
@onready var name_label: Label = $NameLabel
@onready var experience_manager: Node = $ExperienceManager
@onready var sword_ability_controller: Node = $Abilities/SwordAbilityController
@onready var weapon_hitbox_component: HitboxComponent = $Visuals/Weapon/WeaponHitboxComponent
@onready var main_ui: Control = $"../../UILayer/MainUI"
@onready var c_inventory: CInventory = $CInventory
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var axe_ability_controller: Node = $Abilities/AxeAbilityController

var number_coliiding_bodies = 0
var auto_attack = true
var auto_attack_timer: float = 0.0
var init_position: Vector2 = Vector2(100, 100)
var option_enabled = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	damage_interval_timer.timeout.connect(on_damage_interval_timer_timeout)
	health_component.health_changed.connect(on_health_changed)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	experience_manager.level_up.connect(on_level_up)
	main_ui.attack_mode_changed.connect(on_attack_mode_changed)
	update_attributes()
	init_position = self.global_position
	health_component.init_position = init_position
	c_inventory.equip_changed_calcul.connect(on_equip_changed_calcul)
	Global.player_info.is_new = false


func update_attributes(is_revert: bool = true) -> void:
	name_label.text = Global.player_info.name + " Lv." + str(Global.player_info.level)
	health_component.max_health = Global.player_info.生命值
	if is_revert:
		health_component.current_health = Global.player_info.生命值
	health_component.player_health_changed.emit(health_component.current_health, Global.player_info.生命值)
	hurtbox_component.defense = Global.player_info.防御力
	update_health_display()
	sword_ability_controller.basic_damage = Global.player_info.攻击力
	axe_ability_controller.basic_damage = Global.player_info.攻击力
	weapon_hitbox_component.damage = Global.player_info.攻击力
	GameEvents.emit_player_stats_changed(Global.player_info)


func update_health_display():
	health_bar.value = health_component.get_health_percent()


func _process(delta: float) -> void:
	if !option_enabled:
		$AnimationPlayer.play("RESET")
		return
	if !auto_attack:
		var direction = get_movement_vector().normalized()
		var target_velocity = direction * MAX_SPEED
		velocity = velocity.lerp(target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))
		move_and_slide()
	
		if direction.x != 0 || direction.y != 0:
			animation_player.play("walk")
		else:
			animation_player.play("RESET")
	
		var move_sign = sign(direction.x)
		if move_sign != 0:
			visuals.scale = Vector2(move_sign, 1)
	else:
		auto_attack_timer -= delta
		handle_auto_attack(delta)


func handle_auto_attack(delta: float):
	var nearest_enemy = find_nearest_enemy()
	if nearest_enemy:
		var direction = (nearest_enemy.global_position - global_position).normalized()
		var distance = global_position.distance_to(nearest_enemy.global_position)
		
		# 朝向敌人
		var move_sign = sign(direction.x)
		if move_sign != 0:
			visuals.scale = Vector2(move_sign, 1)
		
		# 移动逻辑
		if distance > attack_range:
			# 向敌人移动
			var target_velocity = direction * MAX_SPEED
			velocity = velocity.lerp(target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))
			move_and_slide()
			animation_player.play("walk")
		elif auto_attack_timer <= 0:
			# 在攻击范围内且冷却结束，执行攻击
			attack_animation_player.play("common_attack")
			auto_attack_timer = auto_attack_cooldown
	else:
		# 没有找到敌人，停止移动
		velocity = Vector2.ZERO
		animation_player.play("RESET")


func find_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.size() == 0:
		return null
	
	var nearest_enemy = null
	var min_distance = INF
	
	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest_enemy = enemy
	
	return nearest_enemy


func get_movement_vector():
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return Vector2(x_movement, y_movement)


func check_deal_damage():
	if number_coliiding_bodies == 0 || !damage_interval_timer.is_stopped():
		return
	health_component.damage(1)
	damage_interval_timer.start()


# 修改原有_input函数，避免在自动模式下响应手动攻击
func _input(event: InputEvent) -> void:
	if auto_attack:
		return
		
	if event.is_action_pressed("common_attack"):
		if cd_common_timer.is_stopped():
			attack_animation_player.play("common_attack")
			cd_common_timer.start()
		else:
			push_warning("冷却中")


func set_option_enabled(enabled: bool):
	option_enabled = enabled


func on_damage_interval_timer_timeout():
	check_deal_damage()


func on_health_changed():
	if option_enabled:
		GameEvents.emit_player_damaged()
	update_health_display()
	if option_enabled:
		$HitRandomStreamPlayer2DComponent.play_random()


func on_ability_upgrade_added(ability_upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if not ability_upgrade is Ability:
		return

	var ability = ability_upgrade as Ability
	abilities.add_child(ability.ability_controller_scene.instantiate())


func on_level_up(current_level: int):
	update_attributes()


func on_attack_mode_changed(auto: bool):
	auto_attack = auto


func on_equip_changed_calcul(old: EquipDrop, new: EquipDrop):
	# 计算属性差值并更新玩家属性
	var diff = calculate_equip_diff(old, new)
	apply_equip_diff(diff)

# 计算装备属性差值
func calculate_equip_diff(old_equip: EquipDrop, new_equip: EquipDrop) -> Dictionary:
	var diff = {
		"attack": 0,
		"defense": 0,
		"health": 0,
		"speed": 0,
		"bonus": {}
	}
	
	# 处理旧装备属性（减去）
	if old_equip:
		var old_stats = old_equip.get_full_stats()
		diff["attack"] -= old_stats["attack"]
		diff["defense"] -= old_stats["defense"]
		diff["health"] -= old_stats["health"]
		diff["speed"] -= old_stats["speed"]
		
		# 处理附加属性
		for bonus in old_stats["bonus"]:
			var attr_type = bonus["type"]
			diff["bonus"][attr_type] = diff["bonus"].get(attr_type, 0) - bonus["value"]
	
	# 处理新装备属性（加上）
	if new_equip:
		var new_stats = new_equip.get_full_stats()
		diff["attack"] += new_stats["attack"]
		diff["defense"] += new_stats["defense"]
		diff["health"] += new_stats["health"]
		diff["speed"] += new_stats["speed"]
		
		# 处理附加属性
		for bonus in new_stats["bonus"]:
			var attr_type = bonus["type"]
			diff["bonus"][attr_type] = diff["bonus"].get(attr_type, 0) + bonus["value"]
	
	return diff

# 应用装备差值到玩家属性
func apply_equip_diff(diff: Dictionary):
	# 基础属性
	Global.player_info.equip_attack += diff["attack"]
	Global.player_info.攻击力 += diff["attack"]
	Global.player_info.equip_defense += diff["defense"]
	Global.player_info.防御力 += diff.get("defense", 0)
	Global.player_info.equip_health += diff["health"]
	Global.player_info.生命值 += diff["health"]
	# 更新UI和组件
	update_attributes(false)
	
	# 处理附加属性（示例，根据你的实际系统调整）
	#for attr_type in diff["bonus"]:
		#var value = diff["bonus"][attr_type]
		#match attr_type:
			#"暴击率":
				#sword_ability_controller.crit_chance += value
			#"攻速":
				#auto_attack_cooldown = max(0.1, auto_attack_cooldown - value * 0.01)
			#"吸血":
				#weapon_hitbox_component.lifesteal_rate += value * 0.01
			# 添加其他属性处理...
	
	# 通知属性变化
	GameEvents.emit_player_stats_changed(Global.player_info)
