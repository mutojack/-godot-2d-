extends Resource
class_name MySettings

@export var sfx_v: float = 1
@export var music_v: float = 1
@export var is_all_screen: bool = true


func set_is_all_screen(value: bool):
	is_all_screen = value


func set_sfx_v(value: float):
	sfx_v = value


func set_music_v(value: float):
	music_v = value


# 存档功能
func save_to_file(path: String = "user://player_settings.tres") -> void:
	# 创建资源副本防止运行时修改影响存档
	var save_resource = self.duplicate(true)
	
	# 保存资源
	var error = ResourceSaver.save(save_resource, path)
	if error != OK:
		push_error("设置存档失败！错误码: %d" % error)
	else:
		print("设置存档成功：", path)
		print("设置最终保存路径:", OS.get_user_data_dir().path_join("player_settings.tres"))

# 静态方法用于加载存档
static func load_from_file(path: String = "user://player_settings.tres") -> MySettings:
	# 检查文件是否存在
	if not ResourceLoader.exists(path):
		push_warning("设置存档文件不存在，创建新设置")
		return MySettings.new()
	
	# 加载资源
	var loaded_resource = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	if not loaded_resource is MySettings:
		push_error("设置存档文件损坏，创建新设置")
		return MySettings.new()
	
	print("设置读档成功：", path)
	return loaded_resource
