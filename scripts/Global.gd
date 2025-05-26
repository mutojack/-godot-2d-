extends Node

# 通过 AutoLoad 全局访问的 Player 实例
var player_info: Player = null
var my_settings: MySettings = null

var tech_book: BasicDrop = preload("res://resouces/drop/tech_book.tres")
var axe_ability: Ability = preload("res://resouces/upgrades/axe.tres")
var sword_ability: Ability = preload("res://resouces/upgrades/sword.tres")


func _ready() -> void:
	if !player_info:
		player_info = Player.load_from_file()
	
	if !my_settings:
		my_settings = MySettings.load_from_file()
	
	init_settings()
	load_all_resources()


func init_settings():
	set_volumn('sfx', my_settings.sfx_v)
	set_volumn('music', my_settings.music_v)
	if my_settings.is_all_screen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func set_volumn(bus_name: String, percent: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volumn_db = linear_to_db(percent)
	AudioServer.set_bus_volume_db(bus_index, volumn_db)


# 存储所有资源
func save_all_resources():
	save_resource(tech_book, "user://tech_book.tres")
	save_resource(axe_ability, "user://axe_ability.tres")
	save_resource(sword_ability, "user://sword_ability.tres")


# 加载所有资源
func load_all_resources():
	tech_book = load_resource("user://tech_book.tres", tech_book)
	axe_ability = load_resource("user://axe_ability.tres", axe_ability)
	sword_ability = load_resource("user://sword_ability.tres", sword_ability)


# 通用存储方法
func save_resource(resource: Resource, path: String) -> void:
	var error = ResourceSaver.save(resource, path)
	if error != OK:
		push_error("存档失败: %s, 错误码: %d" % [path, error])
	else:
		print("存档成功:", path)


func load_resource(path: String, default: Resource) -> Resource:
	if ResourceLoader.exists(path):
		var loaded = ResourceLoader.load(path)
		if loaded != null and loaded.get_script() == default.get_script():  # 更安全的类型检查
			print("读档成功:", path)
			return loaded
		else:
			push_error("类型不匹配或加载失败:", path)
	print("使用默认资源:", path)
	return default
