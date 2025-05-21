extends W_ItemSlot
class_name W_EquipSloat

const EQUIP_LABEL_MAPPER: Array[String] = [
	"胸甲",
	"靴子",
	"头盔",
	"项链",
	"戒指",
	"武器",
]
@onready var label: Label = $Label

@export var equip_slot_name: StringName = ""
@export var equip_type: EquipDrop.EQUIP_TYPE = EquipDrop.EQUIP_TYPE.CHEST:
	set(value):
		equip_type = value
		if label:
			label.text = EQUIP_LABEL_MAPPER[value]


func _ready() -> void:
	update_slot_display()
	super()


func update_slot_display():
	label.text = EQUIP_LABEL_MAPPER[equip_type]
