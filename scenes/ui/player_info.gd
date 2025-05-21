extends MarginContainer
@onready var basic_label: Label = %BasicLabel
@onready var attribute_label: Label = %AttributeLabel
@onready var outline_label: Label = %OutlineLabel
@onready var close_btn: Button = %CloseBtn
@onready var collect_experience_btn: Button = %CollectExperienceBtn


func _ready() -> void:
	GameEvents.player_stats_changed.connect(_on_player_stats_changed)
	close_btn.pressed.connect(_on_close_btn_pressed)
	collect_experience_btn.pressed.connect(_on_collect_experience_btn_pressed)


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
	if player_info.accumulate_sceconds >= 0:
		outline_label_text += "离线挂机时长 %s\n" % GameUtils.seconds_to_hhmmss(player_info.accumulate_sceconds)
		outline_label_text += "离线挂机经验 %s\n" % GameUtils.calc_outline_experience(player_info.accumulate_sceconds)
	outline_label.text = outline_label_text


func _on_player_stats_changed(player_info: Player):
	fill_label_text(player_info)


func _on_close_btn_pressed():
	hide()


func _on_collect_experience_btn_pressed():
	GameUtils.emit_notify_experience_manager(GameUtils.calc_outline_experience(Global.player_info.accumulate_sceconds))
	Global.player_info.accumulate_sceconds = 0
	fill_label_text(Global.player_info)
