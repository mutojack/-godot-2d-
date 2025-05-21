extends CanvasLayer

signal monster_level_range_selected(min_level: int, max_level: int)  # 信号返回等级范围

@onready var option_button: OptionButton = %OptionButton
@onready var close_button: Button = %CloseButton
@onready var margin_container: MarginContainer = $MarginContainer
@onready var experience_manager: Node = $"../Entities/Player/ExperienceManager"

@export var player_level: int = 5:
	set(value):
		player_level = max(1, value)
		update_options()

@export var levels_per_option: int = 10  # 每个选项包含的等级跨度

var last_selected_combined_id: int = -1  # 保存最后一次选中的组合ID


func _ready():
	if Global.player_info:
		player_level = Global.player_info.level
	update_options()
	option_button.item_selected.connect(_on_option_button_selected)
	close_button.pressed.connect(_on_close_button_pressed)
	experience_manager.level_up.connect(_on_level_up)
	
	# 设置MarginContainer拦截点击
	margin_container.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 添加透明背景
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin_container.add_child(bg)
	bg.z_index = -1


func update_options():
	var previous_id = last_selected_combined_id  # 保存更新前的选择ID
	
	option_button.clear()
	option_button.add_item("根据人物等级配置", -1)  # 第一个固定选项
	
	# 计算当前可选的最高等级段
	var max_unlocked_segment = ceil(float(player_level) / levels_per_option)
	
	# 添加所有已解锁的等级段选项
	for segment in range(1, max_unlocked_segment + 1):
		var min_level = (segment - 1) * levels_per_option + 1
		var max_level = segment * levels_per_option
		var display_text = "怪物等级%d-%d" % [min_level, max_level]
		var combined_id = min_level * 1000 + max_level
		option_button.add_item(display_text, combined_id)
	
	# 恢复之前的选中状态
	var found_index = -1
	for i in range(option_button.item_count):
		if option_button.get_item_id(i) == previous_id:
			found_index = i
			break
	
	if found_index != -1:
		option_button.selected = found_index
		_on_option_button_selected(found_index)
	else:
		option_button.selected = 0
		last_selected_combined_id = option_button.get_item_id(0)
		_on_option_button_selected(0)


func _on_option_button_selected(index: int):
	var combined_id = option_button.get_item_id(index)
	last_selected_combined_id = combined_id  # 更新最后选择的ID
	
	var min_level = combined_id / 1000
	var max_level = combined_id % 1000
	
	# 处理特殊选项"根据人物等级配置"
	if combined_id == -1:
		min_level = 0
		max_level = 0
	
	print("选中范围: 等级%d-%d" % [min_level, max_level])
	monster_level_range_selected.emit(min_level, max_level)


func _on_close_button_pressed():
	self.hide()


func _on_level_up(current_level: int):
	player_level = current_level
	update_options()
