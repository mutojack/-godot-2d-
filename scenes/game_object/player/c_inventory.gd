extends Node
class_name CInventory

const INIT_COUNT = 8

signal item_changed
signal item_packed
signal equip_changed(slot: StringName, equip: EquipDrop, equip_type: EquipDrop.EQUIP_TYPE)
signal equip_changed_calcul(oldEquip: EquipDrop, newEquip: EquipDrop)

@export var item_slot_count: int = 8
@export var item_slot_count_step: int = 4

var items: Array[BasicDrop] = []
var equip_slots: Dictionary = {
	"chest": [ EquipDrop.EQUIP_TYPE.CHEST, null ],
	"feet": [ EquipDrop.EQUIP_TYPE.FEET, null ],
	"head": [ EquipDrop.EQUIP_TYPE.HEAD, null ],
	"necklace": [ EquipDrop.EQUIP_TYPE.NECKLACE, null ],
	"ring1": [ EquipDrop.EQUIP_TYPE.RING, null ],
	"ring2": [ EquipDrop.EQUIP_TYPE.RING, null ],
	"ring3": [ EquipDrop.EQUIP_TYPE.RING, null ],
	"weapon": [ EquipDrop.EQUIP_TYPE.WEAPON, null ],
}

func _ready() -> void:
	items.resize(item_slot_count)
	items = Global.player_info.items
	var base = max(8, items.size())
	item_slot_count = base if base % 4 == 0 else ((base / 4) + 1) * 4
	equip_slots = Global.player_info.equip_slots
	GameEvents.item_collected.connect(on_item_collected)
	GameUtils.item_quantity_removed.connect(on_item_quantity_removed)


func add_item(add_item: BasicDrop) -> void:
	if !add_item: 
		return
	var item = add_item.duplicate(true)
	if try_merge_repeat_item(item):
		item_changed.emit()
		return
	var empty_slot: int = get_empty_item_slot_index()
	if empty_slot == -1:
		item_slot_count += item_slot_count_step
		items.resize(item_slot_count)
		empty_slot = get_empty_item_slot_index()
	items[empty_slot] = item
	item_changed.emit()


func remove_item(remove_item: BasicDrop) -> void:
	if remove_item == null:
		return
	var index: int = 0
	for item in items:
		if item == remove_item:
			items[index] = null
			break
		index += 1
	item_changed.emit()


func pack_items() -> void:
	var temp_items: Array[BasicDrop] = []
	temp_items = items.filter(
		func(item: BasicDrop):
			return item != null
	)
	
	items.clear()
	items.resize(INIT_COUNT)
	item_slot_count = INIT_COUNT
	
	for item in temp_items:
		add_item(item)
	
	var sort_items = items.duplicate()
	sort_items = sort_items.filter(
		func(item: BasicDrop):
			return item != null
	)
	sort_items.sort_custom(
		func(a: BasicDrop, b: BasicDrop):
			if a.type == b.type && a.type == BasicDrop.TYPE_ENUM.EQUIPMENT:
				return a.equip_type - b.equip_type > 0
			else: 
				return a.type - b.type < 0
	)
	
	items = sort_items
	
	item_packed.emit()


func try_merge_repeat_item(item: BasicDrop) -> bool:
	for it in items:
		if !it:
			continue
		if it.id == item.id:
			if !it.is_max_stack():
				it.merge(item)
				if item.quantity > 0:
					return false
				return true
	return false


func get_empty_item_slot_index() -> int:
	var index: int = 0
	for slot in items:
		if slot == null:
			return index
		index += 1
	return -1


func on_item_collected(item: BasicDrop):
	add_item(item)
	print("====掉落物===")
	print("item:", item)
	print("item.id:", item.id)
	print("item.texture", item.texture)
	print("============")
	Global.player_info.save_to_file()


func use_item(item: BasicDrop) -> void:
	if !item:
		return
	if item.type == BasicDrop.TYPE_ENUM.EQUIPMENT:
		equip_item(item)
	if item.type == BasicDrop.TYPE_ENUM.CONSUMABLE:
		GameEvents.emit_use_consumable(item)


func equip_item(equip: EquipDrop) -> void:
	items[items.find(equip)] = null
	var empty_equip_slot: StringName = _get_empty_equip_slot_name(equip)
	if empty_equip_slot != "":
		equip_slots[empty_equip_slot][1] = equip
		equip_changed.emit(empty_equip_slot, equip, equip.equip_type)
		item_changed.emit()
		equip_changed_calcul.emit(null, equip)
	else:
		var slot: String = _get_equip_slot(equip)
		var old_equip: EquipDrop = equip_slots[slot][1]
		equip_slots[slot][1] = equip
		add_item(old_equip)
		equip_changed.emit(slot, equip, equip.equip_type)
		equip_changed_calcul.emit(old_equip, equip)


func unequip_item(equip: EquipDrop) -> void:
	var slot: StringName = ""
	for s in equip_slots:
		if equip == equip_slots[s][1]:
			slot = s
			break
	if slot.is_empty():
		return
	add_item(equip)
	equip_slots[slot][1] = null
	equip_changed.emit(slot, null, equip.equip_type) 
	equip_changed_calcul.emit(equip, null)
	

func _get_equip_slot(equip: EquipDrop) -> StringName:
	var equip_type: EquipDrop.EQUIP_TYPE = equip.equip_type
	for slot_name in equip_slots:
		var slot_type: EquipDrop.EQUIP_TYPE = equip_slots[slot_name][0]
		var slot_equip: EquipDrop = equip_slots[slot_name][1]
		if slot_type == equip_type:
			return slot_name
	
	return ""


func _get_empty_equip_slot_name(equip: EquipDrop) -> StringName:
	var equip_type: EquipDrop.EQUIP_TYPE = equip.equip_type
	for slot_name in equip_slots:
		var slot_type: EquipDrop.EQUIP_TYPE = equip_slots[slot_name][0]
		var slot_equip: EquipDrop = equip_slots[slot_name][1]
		if slot_type == equip_type and slot_equip == null:
			return slot_name
	
	return ""


func on_item_quantity_removed(remove_item: BasicDrop):
	remove_item(remove_item)
