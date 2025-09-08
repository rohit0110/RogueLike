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
	var head_instance = head_scene.instantiate()
	_disable_jump_loop(head_instance)
	head_slot.add_child(head_instance)

func _disable_jump_loop(node: Node):
	if not node:
		return
	var anim_player = node.get_node_or_null("AnimationPlayer")
	if anim_player and anim_player.has_animation("jump"):
		anim_player.get_animation("jump").loop_mode = Animation.LOOP_NONE
	
# Body part swap scenes -> Path of replacing body part is needed
func swap_right_arm(arm_path: String):
	if current_right_arm:
		current_right_arm.queue_free()
		
	var arm_scene = load(arm_path)
	current_right_arm = arm_scene.instantiate()
	_disable_jump_loop(current_right_arm)
	right_arm_slot.add_child(current_right_arm)

func swap_left_arm(arm_path : String):
	if current_left_arm:
		current_left_arm.queue_free()
		
	var arm_scene = load(arm_path)
	current_left_arm = arm_scene.instantiate()
	_disable_jump_loop(current_left_arm)
	left_arm_slot.add_child(current_left_arm)

func swap_left_leg(leg_path: String):
	if current_left_leg:
		current_left_leg.queue_free()
	
	var leg_scene = load(leg_path)
	current_left_leg = leg_scene.instantiate()
	_disable_jump_loop(current_left_leg)
	left_leg_slot.add_child(current_left_leg)
	
func swap_torso(torso_path: String):
	if current_torso:
		current_torso.queue_free()
	
	var torso_scene = load(torso_path)
	current_torso = torso_scene.instantiate()
	_disable_jump_loop(current_torso)
	torso_slot.add_child(current_torso)

func swap_right_leg(leg_path: String):
	if current_right_leg:
		current_right_leg.queue_free()
	
	var leg_scene = load(leg_path)
	current_right_leg = leg_scene.instantiate()
	_disable_jump_loop(current_right_leg)
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

	# Attacking
	if Input.is_action_just_pressed("attack"):
		# Assuming right arm attacks for now. Can be made more complex.
		if current_right_arm and current_right_arm.has_method("trigger_attack"):
			current_right_arm.trigger_attack()
	
	if Input.is_action_just_pressed("change_arm"):
		swap_left_arm("res://Scenes/Player/Body Part Scenes/Arms/test_arm.tscn")

	move_and_slide()

	_update_all_animations()

func _update_all_animations():
	var is_in_air = not is_on_floor()
	var direction = sign(velocity.x)

	# Legs
	if current_left_leg and current_left_leg.has_method("update_animation"):
		current_left_leg.update_animation(is_in_air, direction)
	if current_right_leg and current_right_leg.has_method("update_animation"):
		current_right_leg.update_animation(is_in_air, direction)
		
	# Arms
	if current_left_arm and current_left_arm.has_method("update_animation"):
		current_left_arm.update_animation(is_in_air, direction)
	if current_right_arm and current_right_arm.has_method("update_animation"):
		current_right_arm.update_animation(is_in_air, direction)

	# Torso
	if current_torso:
		var torso_anim_player = current_torso.get_node_or_null("AnimationPlayer")
		if torso_anim_player:
			var anim_name = "idle"
			if is_in_air:
				anim_name = "jump"
			elif direction != 0:
				anim_name = "walk"
			if torso_anim_player.current_animation != anim_name:
				torso_anim_player.play(anim_name)

	# Head
	if head_slot.get_child_count() > 0:
		var head = head_slot.get_child(0)
		var head_anim_player = head.get_node_or_null("AnimationPlayer")
		if head_anim_player:
			var anim_name = "idle"
			if is_in_air:
				anim_name = "jump"
			elif direction != 0:
				anim_name = "walk"
			if head_anim_player.current_animation != anim_name:
				head_anim_player.play(anim_name)
