extends CanvasLayer

var options_scene = preload("res://scenes/ui/options_menu.tscn")
var exiting = false

func _ready() -> void:
	$%PlayButton.pressed.connect(on_play_pressed)
	$%OptionsButton.pressed.connect(on_options_pressed)
	$%QuitButton.pressed.connect(on_quit_pressed)
	update_outline_info()


func on_play_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")


func on_options_pressed():
	var options_instance = options_scene.instantiate()
	add_child(options_instance)
	options_instance.back_pressed.connect(on_options_closed.bind(options_instance))


func on_quit_pressed():
	if Global.player_info:
		Global.player_info.outline_date_time = Time.get_datetime_dict_from_system()
		Global.player_info.save_to_file()
		Global.my_settings.save_to_file()
	get_tree().quit()


func on_options_closed(options_instance: Node):
	options_instance.queue_free()


func update_outline_info():
	if !Global.player_info || !Global.player_info.outline_date_time:
		return
	Global.player_info.accumulate_sceconds += min(GameUtils.calculate_time_diff(Global.player_info.outline_date_time, 
		Time.get_datetime_dict_from_system()).total_seconds, 60 * 60 * 24)
	print("获取到积累时间：", Global.player_info.accumulate_sceconds)


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST && !exiting:
		exiting = true
		# 直接在主线程保存（适合小数据量）
		if Global.player_info:
			Global.player_info.outline_date_time = Time.get_datetime_dict_from_system()
			Global.player_info.save_to_file()
			Global.my_settings.save_to_file()
		get_tree().quit()
