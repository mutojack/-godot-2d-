extends PanelContainer

var tech: Ability
var tech_book: BasicDrop
@export var type: String 

@onready var name_label: Label = $%NameLabel
@onready var description_label: Label = $%DescriptionLabel
@onready var need_label: Label = %NeedLabel
@onready var upgrade_button: Button = %upgradeButton
@onready var level_label: Label = %LevelLabel


func _ready() -> void:
	if type == "sword":
		tech = Global.sword_ability
	else:
		tech = Global.axe_ability
	tech_book = Global.tech_book
	upgrade_button.pressed.connect(_on_upgrade_button_pressed)
	GameEvents.upgrade_tech.connect(_on_upgrade_tech)
	update_display()

func disabled_upgrade_button():
	upgrade_button.disabled = true
	upgrade_button.icon = null
	upgrade_button.text = "MAX"
	need_label.text = ""


func update_display():
	name_label.text = tech.name
	description_label.text = tech.description
	need_label.text = str(tech.level * 2 + 1)
	level_label.text = "Lv.%d" % tech.level
	if tech:
		if tech.level == tech.max_level:
			disabled_upgrade_button()
	if tech_book.quantity < tech.level * 2 + 1:
		upgrade_button.disabled = true


func _on_upgrade_button_pressed():
	if tech:
		if tech.level < tech.max_level:
			tech_book.quantity -= tech.level * 2 + 1
			tech.level += 1
			tech.total_additional += tech.additional_step
			GameEvents.emit_upgrade_tech()
			Global.save_all_resources()


func _on_upgrade_tech():
	update_display()
	
