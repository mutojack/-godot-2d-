extends CanvasLayer

var options_scene = preload("res://scenes/ui/options_menu.tscn")
var exiting = false
@onready var accept_dialog: AcceptDialog = $MarginContainer/PanelContainer/AcceptDialog

func _ready() -> void:
	$%PlayButton.pressed.connect(on_play_pressed)
	$%OptionsButton.pressed.connect(on_options_pressed)
	$%QuitButton.pressed.connect(on_quit_pressed)
	%ResetButton.pressed.connect(on_reset_pressed)
	accept_dialog.confirmed.connect(on_accept_confirmed)
	accept_dialog.title = "警告"
	accept_dialog.dialog_text = "确定要重新开始游戏吗？"
	if Global.player_info.is_new:
		$%PlayButton.hide()
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
		Global.save_all_resources()
	get_tree().quit()


func on_options_closed(options_instance: Node):
	options_instance.queue_free()


func on_reset_pressed():
	accept_dialog.popup_centered()


func update_outline_info():
	if !Global.player_info || !Global.player_info.outline_date_time:
		return
	Global.player_info.accumulate_sceconds = min(GameUtils.calculate_time_diff(Global.player_info.outline_date_time, 
		Time.get_datetime_dict_from_system()).total_seconds + Global.player_info.accumulate_sceconds, 60 * 60 * 24)
	print("获取到积累时间：", Global.player_info.accumulate_sceconds)


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST && !exiting:
		exiting = true
		# 直接在主线程保存（适合小数据量）
		if Global.player_info:
			Global.player_info.outline_date_time = Time.get_datetime_dict_from_system()
			Global.player_info.save_to_file()
			Global.my_settings.save_to_file()
			Global.save_all_resources()
		get_tree().quit()


func on_accept_confirmed():
	Global.player_info = Player.new()
	Global.player_info.save_to_file()
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
