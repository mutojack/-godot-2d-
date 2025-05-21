extends CanvasLayer

@export var scene_name: String
@onready var label = $%Label
@onready var scene_name_label: Label = %SceneNameLabel

var current_time: float = 0.0  # 从场景加载开始累计的时间（秒）
var is_timer_running: bool = true  # 控制计时器是否运行

func _ready() -> void:
	# 初始化场景名称显示
	if scene_name:
		scene_name_label.text = scene_name
	
	# 重置计时器（可选）
	reset_timer()

func _process(delta: float) -> void:
	if is_timer_running:
		current_time += delta
		label.text = format_seconds_to_string(current_time)

# 将秒数格式化为 hh:mm:ss
func format_seconds_to_string(seconds: float) -> String:
	var total_seconds = int(seconds)
	var hours = total_seconds / 3600
	var minutes = (total_seconds % 3600) / 60
	var secs = total_seconds % 60
	return "%02d:%02d:%02d" % [hours, minutes, secs]

# ===== 计时器控制方法 =====
func start_timer():
	"""启动计时器"""
	is_timer_running = true

func pause_timer():
	"""暂停计时器"""
	is_timer_running = false

func reset_timer():
	"""重置计时器"""
	current_time = 0.0
	label.text = format_seconds_to_string(current_time)

func get_elapsed_time() -> String:
	"""获取当前已过时间（格式化字符串）"""
	return format_seconds_to_string(current_time)

func get_elapsed_seconds() -> float:
	"""获取当前已过时间（原始秒数）"""
	return current_time
