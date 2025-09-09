extends Node2D

@export var animation_tree : AnimationTree
var playback: AnimationNodeStateMachinePlayback
var attack_state : bool = false
signal shoot(pos, direction)

var bullet_marker : Marker2D
var bullet_scene : PackedScene = preload("res://Scenes/Projectiles/toechondria_bullet.tscn")

func _ready() -> void:
	playback = animation_tree["parameters/playback"]
	bullet_marker = $BulletStartPosition
	# Disable looping on the jump animation
	var anim_player = get_node("AnimationPlayer")
	if anim_player.has_animation("jump"):
		anim_player.get_animation("jump").loop_mode = Animation.LOOP_NONE

func update_animation(is_in_air: bool, direction: float):
	# Don't change animation if an attack is in progress
	if attack_state:
		return

	var anim_player = get_node("AnimationPlayer")

	if is_in_air:
		if animation_tree.active:
			animation_tree.active = false
		if anim_player.current_animation != "jump":
			anim_player.play("jump")
	else:
		if not animation_tree.active:
			animation_tree.active = true
		playback.travel("movement")
		animation_tree["parameters/movement/blend_position"] = direction

func trigger_attack():
	if not attack_state:
		attack_state = true
		# The arm is a child of a slot, which is a child of the Positioning node whose scale is flipped.
		var facing_direction = 1 if get_parent().get_parent().scale.x > 0 else -1
		shoot.emit(bullet_marker.position, facing_direction)
		playback.travel("attack")
		# Timer to reset attack state
		await get_tree().create_timer(0.5).timeout
		attack_state = false

func _on_shoot(pos: Variant, direction: Variant) -> void:
	await get_tree().create_timer(0.2).timeout
	var bullet = bullet_scene.instantiate()
	bullet.global_position = bullet_marker.global_position
	bullet.scale.x = direction
	bullet.direction = (get_global_mouse_position() - bullet_marker.global_position).normalized()
	get_tree().current_scene.add_child(bullet)
