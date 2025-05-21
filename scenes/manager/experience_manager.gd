extends Node

signal experience_updated(current_experience: float, target_experience: float)
signal level_up(new_level: int)

const TARGET_EXPERIENCE_GROWTH = 5

var player_info: Player
var current_experience = 0
var current_level = 1
var target_experience = 1


func _ready() -> void:
	GameEvents.experience_vial_collected.connect(on_experience_vial_collected)
	GameUtils.notify_experience_manager.connect(on_notify_experience_manager)
	update_experience()

func update_experience():
	if Global.player_info:
		print("Current Exp:", Global.player_info.经验)
	
	# 更新成员变量 player_info
	player_info = Global.player_info
	if !player_info:
		push_error("PlayerInfo is null!")
		return
	
	# 同步数据
	current_experience = player_info.经验
	current_level = player_info.level
	target_experience = player_info.get_exp_to_next_level()
	experience_updated.emit(current_experience, target_experience)
	
	# 打印最终值
	print("Synced Exp:", current_experience, "Level:", current_level, "Target:", target_experience)


func increment_experience(number: int):
	print("获取经验: ", number)
	if !player_info:
		push_error("PlayerInfo is null in increment_experience!")
		return

	# 初始化剩余经验
	var remaining_experience = number
	var is_level_up = false
	# 循环处理多级升级
	while remaining_experience > 0:
		# 计算当前等级需要的总经验
		target_experience = player_info.get_exp_to_next_level()
		
		# 计算可升到下一级的可用经验
		var experience_to_next_level = target_experience - player_info.经验
		
		# 如果剩余经验不足以升级则直接增加
		if remaining_experience < experience_to_next_level:
			player_info.经验 += remaining_experience
			current_experience = player_info.经验
			remaining_experience = 0
		else:
			# 升级处理
			remaining_experience -= experience_to_next_level
			player_info.level += 1
			player_info.经验 = 0  # 重置为0开始累积下一级经验
			
			# 触发升级事件
			level_up.emit(player_info.level)
			print("升级到:", player_info.level)
			is_level_up = true
			# 更新下一级所需经验
			target_experience = player_info.get_exp_to_next_level()

		# 更新界面显示
		experience_updated.emit(player_info.经验, target_experience)
		if is_level_up:
			GameEvents.emit_level_up_play()

	# 最终保存数据
	Global.player_info.save_to_file()
	print("最终等级:", player_info.level)
	print("当前经验:", player_info.经验)
	print("下一级需要:", target_experience)
	

func on_experience_vial_collected(number: int):
	increment_experience(number)


func on_notify_experience_manager(exp: int):
	increment_experience(exp)
