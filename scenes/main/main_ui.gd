extends Control

signal attack_mode_changed(auto: bool)

@onready var pakage_button: Button = $PakageButton
@onready var w_inventory: MarginContainer = %WInventory
@onready var auto_fire_button: Button = %AutoFireButton

func _ready() -> void:
	pakage_button.pressed.connect(_on_pakage_button_pressed)
	auto_fire_button.pressed.connect(_on_auto_fire_button_pressed)
	auto_fire_button.shortcut_in_tooltip = false
	auto_fire_button.focus_mode = Control.FOCUS_NONE
	
	# 初始化按钮样式
	_update_button_style()

func handleInventory() -> void:
	w_inventory.visible = !w_inventory.visible
	get_tree().paused = w_inventory.visible

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("open_inventory"):
		handleInventory()

func _on_pakage_button_pressed() -> void:
	handleInventory()

func _on_auto_fire_button_pressed() -> void:
	_update_button_style()

# 新增的统一样式更新函数
func _update_button_style():
	# 创建三种状态的基础样式
	var open = true
	var style_normal = StyleBoxFlat.new()
	var style_hover = StyleBoxFlat.new()
	var style_pressed = StyleBoxFlat.new()
	
	# 公共样式设置
	for style in [style_normal, style_hover, style_pressed]:
		style.corner_radius_top_left = 4
		style.corner_radius_top_right = 4
		style.corner_radius_bottom_right = 4
		style.corner_radius_bottom_left = 4
		style.border_width_left = 1
		style.border_width_right = 1
		style.border_width_top = 1
		style.border_width_bottom = 1
		style.border_color = Color(0.8, 0.8, 0.8)
	
	# 根据当前状态设置颜色
	if auto_fire_button.text == "开启":
		attack_mode_changed.emit(false)
		open = false
		auto_fire_button.text = "关闭"
		style_normal.bg_color = Color(0.5, 0.5, 0.5)  # 灰色关闭状态
		style_hover.bg_color = Color(0.6, 0.6, 0.6)   # 悬停稍亮
		style_pressed.bg_color = Color(0.4, 0.4, 0.4) # 按下稍暗
	else:
		attack_mode_changed.emit(true)
		auto_fire_button.text = "开启"
		style_normal.bg_color = Color("#337399")      # 你的蓝色开启状态
		style_hover.bg_color = Color("#3F8DBB")      # 悬停稍亮
		style_pressed.bg_color = Color("#2A6688")    # 按下稍暗
	
	# 应用所有状态样式
	auto_fire_button.add_theme_stylebox_override("normal", style_normal)
	auto_fire_button.add_theme_stylebox_override("hover", style_hover)
	auto_fire_button.add_theme_stylebox_override("pressed", style_pressed)
	auto_fire_button.add_theme_stylebox_override("focus", style_normal)  # 虽然禁用了焦点，但最好也设置
	auto_fire_button.add_theme_stylebox_override("disabled", style_normal)  # 禁用状态
	GameEvents.emit_auto_fire_changed(open)
