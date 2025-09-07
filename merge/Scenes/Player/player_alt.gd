@tool
extends CharacterBody2D


var move_speed_pixels : int = 10
var current_left_arm : Node2D = null
var current_right_arm : Node2D = null
var current_left_leg : Node2D = null
var current_torso : Node2D = null
var current_right_leg : Node2D = null


@onready var left_arm_slot = $LeftArm
@onready var head_slot = $Head
@onready var right_arm_slot = $RightArm
@onready var left_leg_slot = $LeftLeg
@onready var torso_slot = $Torso
@onready var right_leg_slot = $RightLeg
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	InputMap.load_from_project_settings()
	swap_left_arm("res://Scenes/Player/BodyPartScenes/RigArms/RigLeftArm.tscn")
	swap_right_arm("res://Scenes/Player/BodyPartScenes/RigArms/RigRightArm.tscn")
	swap_left_leg("res://Scenes/Player/BodyPartScenes/RigLegs/RigLeftLeg.tscn")
	swap_torso("res://Scenes/Player/BodyPartScenes/RigTorso/RigTorso.tscn")
	swap_right_leg("res://Scenes/Player/BodyPartScenes/RigLegs/RigRightLeg.tscn")
	var head_scene = load("res://Scenes/Player/BodyPartScenes/RigHead/RigHead.tscn")
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
		$".".scale.x = 1
		position.x += move_speed_pixels
	
	if Input.is_action_pressed("move_left"):
		$".".scale.x = -1
		position.x -= move_speed_pixels
		
	if Input.is_action_pressed("move_down"):
		position.y += move_speed_pixels
	
	if Input.is_action_pressed("jump"):
		position.y -= move_speed_pixels
		
	if Input.is_action_just_pressed("change_arm"):
		swap_left_arm("res://Scenes/Player/BodyPartScenes/Arms/test_arm.tscn")
	
