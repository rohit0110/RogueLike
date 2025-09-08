extends Node2D

@export var animation_tree : AnimationTree
var playback: AnimationNodeStateMachinePlayback
var direction : int = 0
var last_direction : int = -1
@onready var anim = $AnimationPlayer

func _ready() -> void:
	playback = animation_tree["parameters/playback"]


func _process(_delta: float) -> void:
	if Input.is_action_pressed("move_right"):
		last_direction = 1
		direction = 1
	elif Input.is_action_pressed("move_left"):
		last_direction = -1
		direction = -1
	else:
		direction = 0
		
	select_animation()
	update_animation_parameters()
	
	
func select_animation():
	playback.travel("movement")
	
func update_animation_parameters():
	animation_tree["parameters/movement/blend_position"] = direction
