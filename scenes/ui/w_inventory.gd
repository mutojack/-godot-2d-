extends MarginContainer

const W_ITEM_SLOT = preload("res://scenes/ui/w_item_slot.tscn")

var c_inventory : CInventory = null
var current_category: int = 0 
var selected_item_slot: int = -1 : set = _selected_item_slot_setter

@onready var grid_container: GridContainer = %GridContainer
@onready var tab_bar: TabBar = %TabBar
@onready var close_btn: Button = %CloseBtn
@onready var decompose_btn: Button = %DecomposeBtn
@onready var pack_btn: Button = %PackBtn
@onready var w_inventory: MarginContainer = $"."
@onready var scroll_container: ScrollContainer = %ScrollContainer


func _ready() -> void:
	tab_bar.tab_changed.connect(_on_tab_changed)
	current_category = tab_bar.current_tab
	close_btn.pressed.connect(_on_close_btn_pressed)
	decompose_btn.pressed.connect(_on_decompose_btn_pressed)
	pack_btn.pressed.connect(_on_pack_btn_pressed)
	for slot: W_EquipSloat in get_tree().get_nodes_in_group("equip_slot_widget"):
		slot.mouse_button_right_pressed.connect(_on_item_slot_mouse_right_pressed.bind(slot))
		slot.reset_selected.connect(_on_reset_selected)


func initialize() -> void:
	c_inventory.item_changed.connect(_on_item_changed)
	c_inventory.item_packed.connect(_on_item_packed)
	c_inventory.equip_changed.connect(_on_equip_changed)
	init_slot()


func init_slot():
	for w_item_slot in grid_container.get_children():
		w_item_slot.queue_free()
	for i in c_inventory.item_slot_count:
		var w_item_slot: W_ItemSlot = W_ITEM_SLOT.instantiate()
		w_item_slot.mouse_button_left_pressed.connect(_on_item_slot_mouse_left_pressed.bind(i))
		w_item_slot.mouse_button_right_pressed.connect(_on_item_slot_mouse_right_pressed.bind(w_item_slot))
		w_item_slot.reset_selected.connect(_on_reset_selected)
		grid_container.add_child(w_item_slot)


func update_slot():
	for i in c_inventory.item_slot_count_step:
		var index = i + (c_inventory.item_slot_count - c_inventory.item_slot_count_step)
		var w_item_slot: W_ItemSlot = W_ITEM_SLOT.instantiate()
		w_item_slot.mouse_button_left_pressed.connect(_on_item_slot_mouse_left_pressed.bind(index))
		w_item_slot.mouse_button_right_pressed.connect(_on_item_slot_mouse_right_pressed.bind(w_item_slot))
		w_item_slot.reset_selected.connect(_on_reset_selected)
		grid_container.add_child(w_item_slot)


func get_category_items() -> Array[BasicDrop]:
	var min_size = c_inventory.item_slot_count
	var items: Array[BasicDrop] = c_inventory.items
	if current_category == 0:
		return items
	var filter_items:  Array[BasicDrop] = items.filter(
		func(item: BasicDrop) -> bool:
			if item == null: return false
			return item.type == current_category
	)
	if filter_items.size() < min_size:
		filter_items.resize(min_size)
	return filter_items


func update_items_display() -> void:
	var items: Array[BasicDrop] = get_category_items()
	var index: int = 0
	for item in items:
		if index >= grid_container.get_children().size():
			update_slot()
		var slot = grid_container.get_child(index)
		slot.item = item
		index += 1
	
	

func _on_item_changed() -> void:
	update_items_display()


func _on_tab_changed(tab: int) -> void:
	current_category = tab
	scroll_container.scroll_vertical = 0
	init_slot()
	await get_tree().process_frame
	update_items_display()


func _on_item_slot_mouse_left_pressed(index: int) -> void:
	selected_item_slot = index


func _selected_item_slot_setter(value: int) -> void:
	if selected_item_slot != -1:
		if selected_item_slot >= grid_container.get_children().size():
			selected_item_slot = -1
			return
		var slot = grid_container.get_child(selected_item_slot)
		if slot == null:
			return
		slot.disselected()
	selected_item_slot = value
	var new_slot = grid_container.get_child(selected_item_slot)
	new_slot.selected()


func _on_close_btn_pressed() -> void:
	w_inventory.visible = false
	get_tree().paused = false


func _on_decompose_btn_pressed() -> void:
	if selected_item_slot == -1:
		return
	var slot: W_ItemSlot = get_slot(selected_item_slot)
	if !slot:
		return
	var item = slot.item
	if item:
		c_inventory.remove_item(item)


func get_slot(index: int) -> W_ItemSlot:
	if index < 0 or index >= grid_container.get_children().size():
		return null
	return grid_container.get_child(index)


func _on_pack_btn_pressed() -> void:
	c_inventory.pack_items()


func _on_item_packed() -> void:
	init_slot()
	await get_tree().process_frame  # 等待格子创建完成
	update_items_display()


func _on_item_slot_mouse_right_pressed(slot: W_ItemSlot) -> void:
	if slot.is_in_group("equip_slot_widget"):
		c_inventory.unequip_item(slot.item)
		slot.nine_patch_rect.modulate = Color.WHITE
	else:
		c_inventory.use_item(slot.item)
		slot.nine_patch_rect.modulate = Color.WHITE


func _on_equip_changed(slot: StringName, equip: EquipDrop, equip_type: EquipDrop.EQUIP_TYPE) -> void:
	for w_equip_slot: W_EquipSloat in get_tree().get_nodes_in_group("equip_slot_widget"):
		if w_equip_slot.equip_slot_name == slot:
			w_equip_slot.item = equip
			w_equip_slot.label.text = ""
			if equip == null:
				w_equip_slot.equip_type = equip_type
			break


func init_equip_slots():
	# 初始化装备槽
	var equip_slots = c_inventory.equip_slots
	for slot in equip_slots:
		for w_equip_slot: W_EquipSloat in get_tree().get_nodes_in_group("equip_slot_widget"):
			if w_equip_slot.equip_slot_name == slot:
				w_equip_slot.item = equip_slots[slot][1]
				w_equip_slot.label.text = ""
				if equip_slots[slot][1] == null:
					w_equip_slot.equip_type = equip_slots[slot][0]
				break


func _on_visibility_changed() -> void:
	if visible:
		if !tab_bar:
			return
		current_category = 0
		tab_bar.current_tab = current_category
		init_equip_slots()
		init_slot()
		await get_tree().process_frame
		update_items_display()


func _on_reset_selected():
	selected_item_slot = -1
	init_slot()
	await get_tree().process_frame  # 等待格子创建完成
	update_items_display()
