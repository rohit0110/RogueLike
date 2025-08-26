extends Node2D

var move_speed_pixels : int = 10
var current_arm : Node2D = null
@onready var arm_slot = $left_arm_slot
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	swap_arm("res://BodyParts/Arms/default_arm.tscn")

func swap_arm(arm_path : String):
	if current_arm:
		current_arm.queue_free()
		
	var arm_scene = load(arm_path)
	current_arm = arm_scene.instantiate()
	arm_slot.add_child(current_arm)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("move_right"):
		position.x += move_speed_pixels
	
	if Input.is_action_pressed("move_left"):
		position.x -= move_speed_pixels
		
	if Input.is_action_pressed("move_down"):
		position.y += move_speed_pixels
	
	if Input.is_action_pressed("jump"):
		position.y -= move_speed_pixels
		
	if Input.is_action_just_pressed("change_arm"):
		swap_arm("res://BodyParts/Arms/test_arm.tscn")
	
	if Input.is_action_just_pressed("attack"):
		current_arm.play_attack()
