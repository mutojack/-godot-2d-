extends CanvasLayer

var tech_book: BasicDrop

@onready var close_button: Button = %CloseButton
@onready var num_label: Label = %NumLabel
@onready var grid_container: GridContainer = %GridContainer


func _ready() -> void:
	tech_book = Global.tech_book
	close_button.pressed.connect(_on_close_button_pressed)
	GameEvents.upgrade_tech.connect(_on_upgrade_tech)
	update_display()

func update_display():
	print("tech_book_quantity   ", tech_book.quantity)
	num_label.text = str(tech_book.quantity)


func _on_upgrade_tech():
	update_display()


func _on_close_button_pressed():
	get_tree().paused = false
	self.queue_free()
