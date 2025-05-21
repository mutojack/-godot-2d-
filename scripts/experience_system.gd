class_name ExperienceSystem

# 根据玩家等级和敌人等级计算实际获得经验值
static func calculate_exp(player_level: int, enemy: Dictionary) -> int:
	var base_exp = enemy["exp_value"]
	var enemy_level = enemy["level"]
	
	# 等级差修正 (鼓励挑战高级敌人)
	var level_diff = enemy_level - player_level
	var exp_multiplier = 1.0
	
	if level_diff > 0:  # 敌人等级更高
		exp_multiplier = 1.0 + max(level_diff * 0.1, 0.2)  # 每高1级多10%经验
	elif level_diff < 0:  # 敌人等级低
		exp_multiplier = max(0.5, 1.0 + (level_diff * 0.05))  # 每低1级少5%，最少50%
	
	# 敌人类型修正
	match enemy["type"]:
		"elite":
			exp_multiplier *= 1.5
		"boss":
			exp_multiplier *= 3.0
	
	return int(base_exp * exp_multiplier)
