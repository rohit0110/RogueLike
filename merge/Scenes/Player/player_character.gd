@tool
extends Node2D

var move_speed_pixels : int = 10
var current_left_arm : Node2D = null
var current_right_arm : Node2D = null
var current_left_leg : Node2D = null
var current_torso : Node2D = null
var current_right_leg : Node2D = null

@onready var left_arm_slot = $RigLeftArm
@onready var head_slot = $RigHead
@onready var right_arm_slot = $RigRightArm
@onready var left_leg_slot = $RigLeftLeg
@onready var torso_slot = $RigTorso
@onready var right_leg_slot = $RigRightLeg

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	swap_left_arm("res://Scenes/Player/Body Part Scenes/RigArms/RigLeftArm.tscn")
	swap_right_arm("res://Scenes/Player/Body Part Scenes/RigArms/RigRightArm.tscn")
	swap_left_leg("res://Scenes/Player/Body Part Scenes/RigLegs/RigLeftLeg.tscn")
	swap_torso("res://Scenes/Player/Body Part Scenes/RigTorso/RigTorso.tscn")
	swap_right_leg("res://Scenes/Player/Body Part Scenes/RigLegs/RigRightLeg.tscn")
	var head_scene = load("res://Scenes/Player/Body Part Scenes/RigHead/RigHead.tscn")
	head_slot.add_child(head_scene.instantiate())
	
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
		swap_left_arm("res://Scenes/Player/Body Part Scenes/Arms/test_arm.tscn")
	
	if Input.is_action_just_pressed("attack"):
		current_left_arm.play_attack()
