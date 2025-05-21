extends BasicDrop
class_name EquipDrop


enum EQUIP_TYPE {
	CHEST,
	FEET,
	HEAD, 
	NECKLACE,
	RING,
	WEAPON, 
}


enum RARITY {
	COMMON,     # 普通（白色）
	ELITE,      # 精英（蓝色）
	EPIC,       # 史诗（紫色）
	LEGENDARY   # 传奇（金色）
}

@export var equip_type: EQUIP_TYPE = EQUIP_TYPE.CHEST
# 基础属性配置
@export var base_attack: int = 0
@export var base_defense: int = 0
@export var base_health: int = 0
@export var base_speed: int = 0

# 成长系数（在tres资源中配置）
@export var attack_growth: float = 1.1
@export var defense_growth: float = 1.08
@export var health_growth: float = 1.15
@export var speed_growth: float = 1.05

@export var rarity: RARITY = RARITY.COMMON
@export var level: int = 1

# 动态生成的属性
@export var calculated_attack: int
@export var calculated_defense: int
@export var calculated_health: int
@export var calculated_speed: int
@export var bonus_attributes: Array[Dictionary]


func _ready():
	generate_stats()

# 根据等级和稀有度生成属性
func generate_stats():
	# 计算基础属性
	var rarity_multiplier = 1.0 + 0.5 * rarity
	
	match equip_type:
		EQUIP_TYPE.WEAPON:
			calculated_attack = int(base_attack * pow(attack_growth, level-1) * rarity_multiplier) + (level - 1) * rarity_multiplier
		EQUIP_TYPE.HEAD, EQUIP_TYPE.CHEST, EQUIP_TYPE.FEET, EQUIP_TYPE.RING:
			calculated_defense = int(base_defense * pow(defense_growth, level-1) * rarity_multiplier) + (level - 1) * rarity_multiplier
		EQUIP_TYPE.NECKLACE:
			calculated_health = int(base_health * pow(health_growth, level-1) * rarity_multiplier) + (level - 1) * rarity_multiplier
			calculated_defense = int(base_defense * pow(defense_growth, level-1) * rarity_multiplier) + (level - 1) * rarity_multiplier
			calculated_attack = int(base_attack * pow(attack_growth, level-1) * rarity_multiplier) + (level - 1) * rarity_multiplier
	
	# 生成附加属性
	generate_bonus_attributes()

func generate_bonus_attributes():
	var possible_attributes = _get_attribute_pool()
	var attribute_count = _get_attribute_count()
	
	bonus_attributes.clear()
	for i in attribute_count:
		var attr = possible_attributes.pick_random()
		var value = _calculate_bonus_value(attr)
		bonus_attributes.append({"type": attr, "value": value})

func _get_attribute_pool() -> Array[String]:
	match equip_type:
		EQUIP_TYPE.WEAPON: 
			return ["暴击率", "攻速", "吸血"]
		EQUIP_TYPE.HEAD: 
			return ["生命回复", "抗性", "经验加成"]
		EQUIP_TYPE.CHEST:
			return ["减伤", "格挡", "反伤"]
		EQUIP_TYPE.FEET:
			return ["闪避", "移动速度", "跳跃强化"]
		EQUIP_TYPE.NECKLACE:
			return ["全属性增强", "金币掉落", "技能冷却"]
		EQUIP_TYPE.RING:
			return ["暴击伤害", "元素伤害", "召唤物强化"]
		_: 
			return []

func _get_attribute_count() -> int:
	match rarity:
		RARITY.COMMON: return 1
		RARITY.ELITE: return 2
		RARITY.EPIC: return 3
		RARITY.LEGENDARY: return 4
		_: return 1

func _calculate_bonus_value(attr: String) -> int:
	var base_value = level
	match attr:
		"暴击率", "吸血", "闪避":
			return int(base_value * 0.5)
		"攻速", "移动速度":
			return int(base_value * 1.2)
		_:
			return base_value

# 获取完整属性字典
func get_full_stats() -> Dictionary:
	return {
		"attack": calculated_attack,
		"defense": calculated_defense,
		"health": calculated_health,
		"speed": calculated_speed,
		"bonus": bonus_attributes
	}
