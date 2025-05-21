extends Resource
class_name EnemyTemplate

enum ENEMY_TYPE {
	NORMAL,
	ELITE,
	BOSS
}


const RARITY_PROBABILITY = {
	ENEMY_TYPE.NORMAL: {
		EquipDrop.RARITY.COMMON: 0.7,
		EquipDrop.RARITY.ELITE: 0.25,
		EquipDrop.RARITY.EPIC: 0.05,
		EquipDrop.RARITY.LEGENDARY: 0.0
	},
	ENEMY_TYPE.ELITE: {
		EquipDrop.RARITY.COMMON: 0.5,
		EquipDrop.RARITY.ELITE: 0.35,
		EquipDrop.RARITY.EPIC: 0.1,
		EquipDrop.RARITY.LEGENDARY: 0.05
	},
	ENEMY_TYPE.BOSS: {
		EquipDrop.RARITY.COMMON: 0.2,
		EquipDrop.RARITY.ELITE: 0.3,
		EquipDrop.RARITY.EPIC: 0.4,
		EquipDrop.RARITY.LEGENDARY: 0.1
	}
}


# 基础属性
@export var enemy_name: String = "普通敌人"
@export var level: int = 1
@export var base_health: int = 50
@export var base_attack: int = 5
@export var base_defense: int = 2
@export var base_speed: int = 80
@export var base_exp: int = 20  # 基础经验值
@export var enemy_type: ENEMY_TYPE = ENEMY_TYPE.NORMAL
@export var accelerate: float = 5.0
@export var health_revert: int = 0
# 成长系数
@export var health_growth: float = 1.1
@export var attack_growth: float = 1.1
@export var defense_growth: float = 1.1
@export var exp_growth: float = 1.05

# 根据等级计算实际属性
func get_scaled_stats(level: int) -> Dictionary:
	var scaled_stats = {
		"max_health": int(base_health * pow(health_growth, level - 1)),
		"attack": int(base_attack * pow(attack_growth, level - 1)),
		"defense": int(base_defense * pow(defense_growth, level - 1)),
		"speed": base_speed,
		"exp_value": int(base_exp * pow(exp_growth, level - 1)),
		"level": level
	}
	return scaled_stats


func setup_scaled_enemy(level: int) -> void:
	var scaled_stats = get_scaled_stats(level)
	base_health = scaled_stats["max_health"]
	base_attack = scaled_stats["attack"]
	base_defense = scaled_stats["defense"]
	base_exp = scaled_stats["exp_value"]
	self.level = level


# 普通敌人 (低血低攻)
static func create_normal_enemy() -> EnemyTemplate:
	var enemy = EnemyTemplate.new()
	enemy.enemy_name = "普通敌人"
	enemy.base_health = 100
	enemy.base_attack = 15
	enemy.base_defense = 6
	enemy.base_exp = 15
	enemy.enemy_type = ENEMY_TYPE.NORMAL
	return enemy

# 精英敌人 (均衡型)
static func create_elite_enemy() -> EnemyTemplate:
	var enemy = EnemyTemplate.new()
	enemy.enemy_name = "精英敌人"
	enemy.base_health = 200
	enemy.base_attack = 16
	enemy.base_defense = 10
	enemy.base_exp = 40
	enemy.enemy_type = ENEMY_TYPE.ELITE
	enemy.health_revert = 1
	return enemy

# BOSS敌人 (高血高攻)
static func create_boss_enemy() -> EnemyTemplate:
	var enemy = EnemyTemplate.new()
	enemy.enemy_name = "BOSS"
	enemy.base_health = 500
	enemy.base_attack = 20
	enemy.base_defense = 12
	enemy.base_exp = 150
	enemy.enemy_type = ENEMY_TYPE.BOSS
	enemy.health_revert = 1
	return enemy


func get_random_rarity() ->EquipDrop.RARITY:
	var rng = randf()
	var probabilities = RARITY_PROBABILITY[enemy_type]
	
	var cumulative = 0.0
	for rarity in probabilities:
		cumulative += probabilities[rarity]
		if rng <= cumulative:
			return rarity
	
	return EquipDrop.RARITY.COMMON
