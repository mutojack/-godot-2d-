extends Control

@onready var dragon_button: Button = $DragonButton
@onready var monster_setting_page: CanvasLayer = %MonsterSettingPage


func _ready() -> void:
	dragon_button.pressed.connect(_on_dragon_button_pressed)


func _on_dragon_button_pressed() -> void:
	monster_setting_page.show()
