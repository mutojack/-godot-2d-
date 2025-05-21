extends Node

# 通过 AutoLoad 全局访问的 Player 实例
var player_info: Player = null
var my_settings: MySettings = null


func _ready() -> void:
	if !player_info:
		player_info = Player.load_from_file()
	
	if !my_settings:
		my_settings = MySettings.load_from_file()
	
	init_settings()


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
	
