extends Node2D

@export var animation_tree : AnimationTree
var playback: AnimationNodeStateMachinePlayback
var attack_state : bool = false
var direction : int = 0

func _ready() -> void:
	playback = animation_tree["parameters/playback"]


func _process(_delta: float) -> void:
	if Input.is_action_pressed("move_right"):
		direction = 1
	elif Input.is_action_pressed("move_left"):
		direction = -1
	else:
		direction = 0
	
	if Input.is_action_just_pressed("attack"):
		attack_state = true
	
	select_animation()
	update_animation_parameters()
	
func select_animation():
	if attack_state:
		playback.travel("attack")
		await get_tree().create_timer(0.5).timeout
		attack_state = false
	else:
		playback.travel("movement")

func update_animation_parameters():
	animation_tree["parameters/movement/blend_position"] = direction
