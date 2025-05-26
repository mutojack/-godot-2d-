extends Node2D

const VALID_TIME = 300

@onready var collision_shape_2d = $Area2D/CollisionShape2D
@onready var sprite = $Sprite2D
@onready var valid_timer: Timer = $ValidTimer

@export var item: BasicDrop
var level: int = 0:
	set(value):
		if item is EquipDrop:
			if value != 0:
				item = item.duplicate(true)
			item.level = value
			item.generate_stats()

var rarity: EquipDrop.RARITY = EquipDrop.RARITY.COMMON:
	set(value):
		if item is EquipDrop:
			item.rarity = value
			item.generate_stats()


func _ready() -> void:
	$Area2D.area_entered.connect(on_area_entered)
	valid_timer.wait_time = VALID_TIME
	valid_timer.timeout.connect(queue_free)
	valid_timer.start()
	if item is BasicDrop && item is not EquipDrop:
		if item.id == '':
			return
		item = item.duplicate(true)


func tween_collect(percent: float, start_position: Vector2):
	var player =  get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	
	global_position = start_position.lerp(player.global_position, percent)
	var direction_from_start = player.global_position - start_position
	
	var target_rotation	 = direction_from_start.angle() + deg_to_rad(90)
	rotation = lerp_angle(rotation, target_rotation, 1 - exp(-2 * get_process_delta_time()))


func collect(item: BasicDrop):
	if item.id == "tech_book":
		item.quantity += 1
		Global.tech_book.quantity += 1
		Global.save_all_resources()
		queue_free()
		return
	GameEvents.emit_item_collected(item)
	queue_free()
	

func disable_collision():
	collision_shape_2d.disabled = true


func on_area_entered(other_area: Area2D):
	Callable(disable_collision).call_deferred()

	var tween = create_tween()
	tween.set_parallel()
	tween.tween_method(tween_collect.bind(global_position), 0.0, 1.0, .5)\
	.set_ease(Tween.EASE_IN)\
	.set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite, "scale", Vector2.ZERO, .15).set_delay(.35)
	tween.chain()
	
	tween.tween_callback(collect.bind(item))
	$RandomStreamPlayer2DComponent.play_random()
