extends Node

# 通过 AutoLoad 全局访问的 Player 实例
var player_info: Player = null


func _ready() -> void:
	if !Global.player_info:
		Global.player_info = Player.load_from_file()
