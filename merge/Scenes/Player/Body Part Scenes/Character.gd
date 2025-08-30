extends CharacterBody2D

@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var rig: Node2D = $Rig   # or the node that holds your sprites

@export var speed: float = 180.0
@export var accel: float = 2000.0
@export var friction: float = 1800.0
@export var jump_vel: float = -380.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var current_arm := preload("res://Scenes/Player/Body Part Scenes/Arms/test_arm.tscn").instantiate()

func _physics_process(delta: float) -> void:
	# input
	var dir := Input.get_axis("ui_left","ui_right")

	# horizontal motion
	var target := dir * speed
	velocity.x = move_toward(velocity.x, target, (accel if dir != 0 else friction) * delta)

	# vertical motion
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_vel
	else:
		velocity.y += gravity * delta

	move_and_slide()

	# face movement direction
	if dir != 0:
		if is_instance_valid(rig): rig.scale.x = -1 if dir < 0 else 1

	if abs(velocity.x) > 1.0:
		ap.play("WalkState")        # keys ...="walk"
	else:
		ap.play("IdleState")        # keys ...="idle"
