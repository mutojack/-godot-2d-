extends MarginContainer
class_name W_ItemSlot

signal mouse_button_left_pressed
signal mouse_button_right_pressed
signal reset_selected

@onready var w_item_tile: MarginContainer = $w_item_tile
@onready var nine_patch_rect: NinePatchRect = $NinePatchRect

var item: BasicDrop = null : set = _item_setter
var is_selected = false


func _ready() -> void:
	gui_input.connect(_on_gui_input)


func selected() -> void:
	var current_color = nine_patch_rect.modulate
	
	if current_color.is_equal_approx(Color.WHITE):
		# 如果是白色，设置为红色（保持原alpha值）
		nine_patch_rect.modulate = Color(242.0 / 255.0, 173.0 / 255.0, 125.0 / 255, 0.7)
	else:
		nine_patch_rect.modulate = Color(
			current_color.r * 0.7,
			current_color.g * 0.7,
			current_color.b * 0.7,
			current_color.a
		)
	
	is_selected = true


func disselected() -> void:
	nine_patch_rect.modulate = Color.WHITE
	set_color_by_rarity()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			mouse_button_left_pressed.emit()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			mouse_button_right_pressed.emit()
			disselected()
			reset_selected.emit()


func _item_setter(value: BasicDrop) -> void:
	item = value
	if item != null:
		set_color_by_rarity()
		w_item_tile.update_display(item)
		w_item_tile.show()
	else:
		w_item_tile.hide()
		

func set_color_by_rarity():
	if item && item is EquipDrop:
		match item.rarity:
			EquipDrop.RARITY.COMMON:
				nine_patch_rect.modulate = Color.WHITE
			EquipDrop.RARITY.ELITE:
				nine_patch_rect.modulate = Color.LIGHT_SKY_BLUE
			EquipDrop.RARITY.EPIC:
				nine_patch_rect.modulate = Color.PURPLE
			EquipDrop.RARITY.LEGENDARY:
				nine_patch_rect.modulate = Color.GOLD
			_:
				nine_patch_rect.modulate = Color.WHITE
	else:
		nine_patch_rect.modulate = Color.WHITE
