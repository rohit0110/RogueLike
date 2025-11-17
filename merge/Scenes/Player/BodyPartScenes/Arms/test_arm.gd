extends Node2D

@export var animation_tree : AnimationTree
var playback: AnimationNodeStateMachinePlayback
var attack_state : bool = false
var original_rotation = rotation
@onready var anim = $AnimationPlayer

func _ready() -> void:
	playback = animation_tree["parameters/playback"]


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		var angle_to_turn : float = get_local_mouse_position().angle()
		if rad_to_deg(angle_to_turn) > 75:
			angle_to_turn = deg_to_rad(75)
		elif rad_to_deg(angle_to_turn) < -75:
			angle_to_turn = deg_to_rad(-75)
		$Rotation.rotation = angle_to_turn
		attack_state = true
		
	select_animation()
	update_animation_parameters()
	
func select_animation():
	if attack_state:
		playback.travel("attack")
		await get_tree().create_timer(0.5).timeout
		attack_state = false
	else:
		$Rotation.rotation = original_rotation
		playback.travel("idle")
		
func update_animation_parameters():
	pass				# DIRECTION FOR MOVEMENT ANIMATION
