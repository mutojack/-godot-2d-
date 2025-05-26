extends Resource
class_name Player

@export var name: String = "无名"
@export var age: int = 18
@export var sex: String = "男"

@export var level: int = 1: set = _level_setter
@export var items: Array[BasicDrop] = []
@export var equip_slots: Dictionary = {
	"chest": [ EquipDrop.EQUIP_TYPE.CHEST, null ],
	"feet": [ EquipDrop.EQUIP_TYPE.FEET, null ],
	"head": [ EquipDrop.EQUIP_TYPE.HEAD, null ],
	"necklace": [ EquipDrop.EQUIP_TYPE.NECKLACE, null ],
	"ring1": [ EquipDrop.EQUIP_TYPE.RING, null ],
	"ring2": [ EquipDrop.EQUIP_TYPE.RING, null ],
	"ring3": [ EquipDrop.EQUIP_TYPE.RING, null ],
	"weapon": [ EquipDrop.EQUIP_TYPE.WEAPON, null ],
}
@export var equip_health: int = 0
@export var equip_attack: int = 0
@export var equip_defense: int = 0
@export var 生命值: int = 100
@export var 攻击力: int = 15
@export var 防御力: int = 6
@export var 每秒回复: int = 1
@export var 经验: int  

# 基础属性值（1级时的属性）
@export var base_health: int = 100
@export var base_attack: int = 15
@export var base_defense: int = 6
@export var base_regen: int = 1

# 成长系数 - 可以调整这些值来平衡游戏
@export var health_growth: float = 1.1  # 生命值成长系数
@export var attack_growth: float = 1.1   # 攻击力成长系数
@export var defense_growth: float = 1.1 # 防御力成长系数
@export var regen_growth: float = 1.05   # 回复成长系数

# 升级所需经验曲线参数
@export var exp_base: int = 100         # 基础经验值
@export var exp_growth: float = 1.2     # 经验成长系数

# 记录时间
@export var outline_date_time: Dictionary
@export var accumulate_sceconds: int = 0
@export var accumulate_experience: int = 0

@export var is_new: bool = true

func _level_setter(value):
	if value <= level or value < 1:
		return  # 不允许降级或设置为无效等级
	
	# 保存旧等级
	var old_level = level
	
	# 设置新等级
	level = value
	
	# 计算属性增长
	_update_attributes(old_level)
	print("升级到 %d 级，新属性: 生命=%d, 攻击=%d, 防御=%d, 回复=%d" % [
		level, 生命值, 攻击力, 防御力, 每秒回复
	])

# 计算升级到当前等级应有的属性
func _update_attributes(from_level: int):
	# 生命值 = 基础值 × (成长系数)^(等级-1)
	生命值 = int(base_health * pow(health_growth, level - 1)) + equip_health
	
	# 攻击力 = 基础值 × (成长系数)^(等级-1)
	攻击力 = int(base_attack * pow(attack_growth, level - 1)) + equip_attack
	
	# 防御力 = 基础值 × (成长系数)^(等级-1)
	防御力 = int(base_defense * pow(defense_growth, level - 1)) + equip_defense
	
	# 每秒回复 = 基础值 × (成长系数)^(等级-1)
	每秒回复 = int(base_regen * pow(regen_growth, level - 1))

# 计算从当前等级升到下一级所需经验值
func get_exp_to_next_level() -> int:
	return int(exp_base * pow(exp_growth, level - 1))

# 重置为1级（保留物品）
func reset():
	level = 1
	_update_attributes(1)


# 获取完整属性字典
func get_full_stats() -> Dictionary:
	return {
		"attack": 攻击力,
		"defense": 防御力,
		"health": 生命值,
	}


# 存档功能
func save_to_file(path: String = "user://player_save.tres") -> void:
	# 创建资源副本防止运行时修改影响存档
	var save_resource = self.duplicate(true)
	
	# 保存资源
	var error = ResourceSaver.save(save_resource, path)
	if error != OK:
		push_error("存档失败！错误码: %d" % error)
	else:
		print("存档成功：", path)
		print("最终保存路径:", OS.get_user_data_dir().path_join("player_save.tres"))

# 静态方法用于加载存档
static func load_from_file(path: String = "user://player_save.tres") -> Player:
	# 检查文件是否存在
	if not ResourceLoader.exists(path):
		push_warning("存档文件不存在，创建新角色")
		return Player.new()
	
	# 加载资源
	var loaded_resource = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	if not loaded_resource is Player:
		push_error("存档文件损坏，创建新角色")
		return Player.new()
	
	print("读档成功：", path)
	print("读档数据====")
	print("health",loaded_resource.生命值)
	return loaded_resource


func get_save_data() -> Dictionary:
	return {
		"name": name,
		"age": age,
		"sex": sex,
		"level": level,
		"items": items,
		"equip_health": equip_health,
		"equip_attack": equip_attack,
		"equip_defense": equip_defense,
		"基础属性": {
			"base_health": base_health,
			"base_attack": base_attack,
			"base_defense": base_defense,
			"base_regen": base_regen
		},
		"成长系数": {
			"health_growth": health_growth,
			"attack_growth": attack_growth,
			"defense_growth": defense_growth,
			"regen_growth": regen_growth
		},
		"经验参数": {
			"exp_base": exp_base,
			"exp_growth": exp_growth
		}
	}


# 从数据加载（用于自定义反序列化）
func load_save_data(data: Dictionary) -> void:
	name = data.get("name", "无名")
	age = data.get("age", 18)
	sex = data.get("sex", "男")
	level = data.get("level", 1)
	items = data.get("items", [])
	# 装备属性
	equip_health = data.get("equip_health", 0)
	equip_attack = data.get("equip_attack", 0)
	equip_defense = data.get("equip_defense", 0)
	# 基础属性
	var base_stats = data.get("基础属性", {})
	base_health = base_stats.get("base_health", 100)
	base_attack = base_stats.get("base_attack", 8)
	base_defense = base_stats.get("base_defense", 2)
	base_regen = base_stats.get("base_regen", 1)
	# 成长系数
	var growth = data.get("成长系数", {})
	health_growth = growth.get("health_growth", 1.15)
	attack_growth = growth.get("attack_growth", 1.1)
	defense_growth = growth.get("defense_growth", 1.08)
	regen_growth = growth.get("regen_growth", 1.05)
	# 经验参数
	var exp_params = data.get("经验参数", {})
	exp_base = exp_params.get("exp_base", 100)
	exp_growth = exp_params.get("exp_growth", 2.0)
	
	# 更新当前等级属性
	_update_attributes(1)
