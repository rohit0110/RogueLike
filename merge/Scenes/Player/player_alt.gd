extends CharacterBody2D


# Current body parts in the scene
@export var move_speed_pixels : int = 5
var current_left_arm : Node2D = null
var current_right_arm : Node2D = null
var current_left_leg : Node2D = null
var current_torso : Node2D = null
var current_right_leg : Node2D = null

var last_direction = 1
@export var jump_force := -400.0
@export var gravity := 900.0

var is_jumping := false




# Body Part Slots. Body parts are added as CHILDREN -> IMP
@onready var left_arm_slot = $Positioning/LeftArm
@onready var head_slot = $Positioning/Head
@onready var right_arm_slot = $Positioning/RightArm
@onready var left_leg_slot = $Positioning/LeftLeg
@onready var torso_slot = $Positioning/Torso
@onready var right_leg_slot = $Positioning/RightLeg

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("player")
	InputMap.load_from_project_settings()
	swap_left_arm("res://Scenes/Player/Body Part Scenes/RigArms/RigLeftArm.tscn")
	swap_right_arm("res://Scenes/Player/Body Part Scenes/RigArms/RigRightArm.tscn")
	swap_left_leg("res://Scenes/Player/Body Part Scenes/RigLegs/RigLeftLeg.tscn")
	swap_torso("res://Scenes/Player/Body Part Scenes/RigTorso/RigTorso.tscn")
	swap_right_leg("res://Scenes/Player/Body Part Scenes/RigLegs/RigRightLeg.tscn")
	var head_scene = load("res://Scenes/Player/Body Part Scenes/RigHead/RigHead.tscn")
	head_slot.add_child(head_scene.instantiate())
	
# Body part swap scenes -> Path of replacing body part is needed
func swap_right_arm(arm_path: String):
	if current_right_arm:
		current_right_arm.queue_free()
		
	var arm_scene = load(arm_path)
	current_right_arm = arm_scene.instantiate()
	right_arm_slot.add_child(current_right_arm)

func swap_left_arm(arm_path : String):
	if current_left_arm:
		current_left_arm.queue_free()
		
	var arm_scene = load(arm_path)
	current_left_arm = arm_scene.instantiate()
	left_arm_slot.add_child(current_left_arm)

func swap_left_leg(leg_path: String):
	if current_left_leg:
		current_left_leg.queue_free()
	
	var leg_scene = load(leg_path)
	current_left_leg = leg_scene.instantiate()
	left_leg_slot.add_child(current_left_leg)
	
func swap_torso(torso_path: String):
	if current_torso:
		current_torso.queue_free()
	
	var torso_scene = load(torso_path)
	current_torso = torso_scene.instantiate()
	torso_slot.add_child(current_torso)

func swap_right_leg(leg_path: String):
	if current_right_leg:
		current_right_leg.queue_free()
	
	var leg_scene = load(leg_path)
	current_right_leg = leg_scene.instantiate()
	right_leg_slot.add_child(current_right_leg)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		is_jumping = false
		if velocity.y > 0:
			velocity.y = 0

	# Horizontal Movement
	var horizontal_input = Input.get_axis("move_left", "move_right")
	velocity.x = horizontal_input * move_speed_pixels

	# Flipping character
	if horizontal_input != 0:
		if $Positioning.scale.x < 0 and horizontal_input > 0:
			$Positioning.scale.x = 1
		elif $Positioning.scale.x > 0 and horizontal_input < 0:
			$Positioning.scale.x = -1

	# Jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
		is_jumping = true
	
	if Input.is_action_just_pressed("change_arm"):
		swap_left_arm("res://Scenes/Player/Body Part Scenes/Arms/test_arm.tscn")

	move_and_slide()
