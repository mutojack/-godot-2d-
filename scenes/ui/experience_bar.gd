extends CanvasLayer

@onready var experience_progress_bar: ProgressBar = %ExperienceProgressBar
@onready var experience_manager: Node = $"../Entities/Player/ExperienceManager"
@onready var experience_label: Label = %ExperienceLabel
@onready var health_component: HealthComponent = $"../Entities/Player/HealthComponent"
@onready var health_label: Label = %HealthLabel
@onready var health_progress_bar: ProgressBar = $MarginContainer/HBoxContainer/VBoxContainer/MarginContainer2/HealthProgressBar
@onready var person_button: Button = %PersonButton
@onready var check_margin_container: MarginContainer = %CheckMarginContainer
@onready var name_label: Label = %NameLabel
@onready var player_info: MarginContainer = %PlayerInfo


func _ready() -> void:
	experience_progress_bar.value = 0
	experience_manager.experience_updated.connect(on_experience_updated)
	experience_manager.level_up.connect(on_level_up)
	health_component.player_health_changed.connect(on_player_health_changed)
	person_button.mouse_entered.connect(on_person_button_mouse_entered)
	person_button.mouse_exited.connect(on_person_button_mouse_exited)
	person_button.pressed.connect(on_person_button_mouse_pressed)
	update_name_label()


func on_experience_updated(current_experience: float, target_experience: float):
	var percent = current_experience / target_experience
	experience_progress_bar.value = percent
	experience_label.text = "%d / %d" % [current_experience, target_experience]


func on_player_health_changed(cur: int, tar: int):
	var percent = float(cur) / float(tar)
	health_progress_bar.value = percent
	health_label.text = "%d / %d" % [cur, tar]


func on_person_button_mouse_entered():
	check_margin_container.show()


func on_person_button_mouse_exited():
	check_margin_container.hide()


func update_name_label():
	if Global.player_info:
		name_label.text = "Lv. %d %s" % [Global.player_info.level, Global.player_info.name]


func on_level_up(cur: int):
	update_name_label()


func on_person_button_mouse_pressed():
	player_info.show()
