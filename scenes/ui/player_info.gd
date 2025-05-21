extends MarginContainer
@onready var basic_label: Label = %BasicLabel
@onready var attribute_label: Label = %AttributeLabel
@onready var outline_label: Label = %OutlineLabel
@onready var close_btn: Button = %CloseBtn


func _ready() -> void:
	GameEvents.player_stats_changed.connect(_on_player_stats_changed)
	close_btn.pressed.connect(_on_close_btn_pressed)


func fill_label_text(player_info: Player):
	var basic_label_text: String = ""
	if player_info.name:
		basic_label_text += "名称 %s\n" % player_info.name
	if player_info.level:
		basic_label_text += "等级 %d\n" % player_info.level
	if player_info.age:
		basic_label_text += "年龄 %d\n" % player_info.age
	if player_info.sex:
		basic_label_text += "性别 %s" % player_info.sex
	basic_label.text = basic_label_text
	
	var attribute_label_text: String = ""
	if player_info.生命值:
		attribute_label_text += "生命值 %d\n" % player_info.生命值
	if player_info.攻击力:
		attribute_label_text += "攻击力 %d\n" % player_info.攻击力
	if player_info.防御力:
		attribute_label_text += "防御力 %d" % player_info.防御力
	attribute_label.text = attribute_label_text
	
	var outline_label_text: String = ""	


func _on_player_stats_changed(player_info: Player):
	fill_label_text(player_info)


func _on_close_btn_pressed():
	hide()
