extends MarginContainer

@onready var label_des: Label = %label_des
@onready var w_attribute_set: MarginContainer = %w_attribute_set
@onready var label_attributes: Label = %label_attributes
@onready var label_item_name: Label = %label_item_name
@onready var h_separator_2: HSeparator = $MarginContainer/VBoxContainer/HSeparator2

func update_display(item: BasicDrop) -> void:
	if !item:
		return
	await ready
	
	w_attribute_set.show()
	label_attributes.text = ""
	
	if item is EquipDrop:
		label_item_name.text = item.name + " Lv.%d" % item.level
	else:
		label_item_name.text = item.name
	label_des.text = item.description

	if item is EquipDrop:
		var equip := item as EquipDrop
		var stats = equip.get_full_stats()
		var attr_text := ""
		
		match equip.equip_type:
			EquipDrop.EQUIP_TYPE.WEAPON:
				if stats.attack != 0:
					attr_text += "攻击力：%d\n" % stats.attack
			EquipDrop.EQUIP_TYPE.HEAD, EquipDrop.EQUIP_TYPE.CHEST, EquipDrop.EQUIP_TYPE.FEET, EquipDrop.EQUIP_TYPE.RING:
				if stats.defense != 0:
					attr_text += "防御力：%d\n" % stats.defense
			EquipDrop.EQUIP_TYPE.NECKLACE:
				if stats.health != 0:
					attr_text += "生命加成：%d\n" % stats.health
				if stats.defense != 0:
					attr_text += "防御力：%d\n" % stats.defense
				if stats.attack != 0:
					attr_text += "攻击力：%d\n" % stats.attack
					
		#目前没有特别属性
		#for bonus in stats.bonus:
			#attr_text += "%s：+%s\n" % [bonus.type, _format_bonus_value(bonus)]
		
		attr_text += "稀有度：%s" % _get_rarity_name(equip.rarity)
		label_attributes.text = attr_text
		if attr_text.is_empty():
			w_attribute_set.hide()
			h_separator_2.hide()
	else:
		w_attribute_set.hide()
		h_separator_2.hide()


func _format_bonus_value(bonus: Dictionary) -> String:
	var value = bonus.value
	match bonus.type:
		"暴击率", "闪避率", "吸血":
			return "%.1f%%" % value
		"攻速":
			return "+%.1f%%" % value
		_:
			return str(value)


func _get_rarity_name(rarity: EquipDrop.RARITY) -> String:
	match rarity:
		EquipDrop.RARITY.COMMON: return "普通"
		EquipDrop.RARITY.ELITE: return "精英"
		EquipDrop.RARITY.EPIC: return "史诗"
		EquipDrop.RARITY.LEGENDARY: return "传奇"
		_: return ""
