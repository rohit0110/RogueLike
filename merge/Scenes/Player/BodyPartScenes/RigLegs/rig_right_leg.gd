extends Node2D

@export var animation_tree : AnimationTree
var playback: AnimationNodeStateMachinePlayback
@onready var anim = $AnimationPlayer

func _ready() -> void:
	playback = animation_tree["parameters/playback"]
	if anim.has_animation("jump"):
		anim.get_animation("jump").loop_mode = Animation.LOOP_NONE

func update_animation(is_in_air: bool, direction: float):
	if is_in_air:
		# The AnimationTree for legs doesn't have a "jump" state.
		# To play the jump animation, we must play it directly and disable the tree.
		if animation_tree.active:
			animation_tree.active = false
		# Check if jump animation is already playing to avoid restarting it every frame
		if anim.current_animation != "jump":
			anim.play("jump")
	else:
		# Re-enable the animation tree for walking/idling.
		if not animation_tree.active:
			animation_tree.active = true
		playback.travel("movement")
		animation_tree["parameters/movement/blend_position"] = direction
