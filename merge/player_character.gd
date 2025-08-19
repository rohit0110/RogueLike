extends Node2D

var move_speed_pixels : int = 10
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
		$LeftArm.region_enabled = false
		$LeftArm.texture = load("res://Assets/test_arm.png")
		$LeftArm.scale = Vector2(2.5,2.5)
		$LeftArm.position = Vector2(490, 183)
