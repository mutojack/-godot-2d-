extends Node

@export var end_screen_scene: PackedScene

var exiting = false
var pause_menu_scene = preload("res://scenes/ui/pause_menu.tscn")

@onready var player: CharacterBody2D = %Player
@onready var w_inventory: MarginContainer = %WInventory


func _ready() -> void:
	player.health_component.died.connect(on_player_died)
	w_inventory.c_inventory = player.get_node("CInventory")
	w_inventory.initialize()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		add_child(pause_menu_scene.instantiate())
		get_tree().root.set_input_as_handled()


func on_player_died():
	#var end_screen_instance = end_screen_scene.instantiate()
	#add_child(end_screen_instance)
	#end_screen_instance.set_defeat()
	#MetaProgression.save()
	pass


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST && !exiting:
		exiting = true
		# 直接在主线程保存（适合小数据量）
		if Global.player_info:
			Global.player_info.save_to_file()
		get_tree().quit()
