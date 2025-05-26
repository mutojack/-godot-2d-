extends Control

@export var tech_scene: PackedScene
@onready var dragon_button: Button = $DragonButton


func _ready() -> void:
	dragon_button.pressed.connect(_on_dragon_button_pressed)


func _on_dragon_button_pressed() -> void:
	var foreground = get_tree().get_first_node_in_group("foreground_layer")
	if tech_scene:
		var tech_scene_instance = tech_scene.instantiate()
		foreground.add_child(tech_scene_instance)
		get_tree().paused = true
