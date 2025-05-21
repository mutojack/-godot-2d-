extends MarginContainer


func _ready() -> void:
	GameEvents.level_up_play.connect(_on_level_up_play)


func _on_level_up_play():
	$AnimationPlayer.play("level_up")
