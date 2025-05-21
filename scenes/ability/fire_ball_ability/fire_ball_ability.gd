extends Node2D
class_name FireBallAbility

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var hitbox_component: HitboxComponent = $HitboxComponent

var speed = 300
var direction := Vector2.RIGHT

func _ready():
	visible_on_screen_notifier_2d.screen_exited.connect(_on_screen_exited)


func set_direction(new_direction: Vector2):
	direction = new_direction
	rotation = direction.angle()


func _process(delta):
	position += direction * speed * delta
	$AnimationPlayer.play("file_change")
	

func _on_screen_exited():
	queue_free()
