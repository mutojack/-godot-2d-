extends MarginContainer

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label
const W_ITEM_TIP = preload("res://scenes/ui/w_item_tip.tscn")
var item: BasicDrop = null


func update_display(item: BasicDrop) -> void:
	self.item = item
	texture_rect.texture = item.texture
	
	if item == null:
		return
	
	if item is EquipDrop:
		label.text = "Lv.%d" % item.level
		return
	
	if item.max_stack <= 1:
		label.hide()
	else:
		label.show()
		label.text = str(item.quantity)


func _make_custom_tooltip(for_text: String) -> Control:
	if !item:
		return null  # 必须显式返回 null 才能清除提示
	
	var item_tip = W_ITEM_TIP.instantiate()
	item_tip.update_display(item)
	return item_tip
	
