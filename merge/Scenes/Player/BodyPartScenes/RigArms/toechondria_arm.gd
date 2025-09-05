extends Node2D

@export var animation_tree : AnimationTree
var playback: AnimationNodeStateMachinePlayback
var attack_state : bool = false
var direction : int = 0
var last_direction : int = -1
signal shoot(pos, direction)

var bullet_marker : Marker2D
var bullet_scene : PackedScene = preload("res://Scenes/Projectiles/toechondria_bullet.tscn")

func _ready() -> void:
	playback = animation_tree["parameters/playback"]
	bullet_marker = $BulletStartPosition


func _process(_delta: float) -> void:
	if Input.is_action_pressed("move_right"):
		last_direction = 1
		direction = 1
	elif Input.is_action_pressed("move_left"):
		last_direction = -1
		direction = -1
	else:
		direction = 0
	
	if Input.is_action_just_pressed("attack"):
		attack_state = true
		shoot.emit(bullet_marker.position, direction)
	
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


func _on_shoot(pos: Variant, direction: Variant) -> void:
	await get_tree().create_timer(0.2).timeout
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position + pos
	bullet.scale.x = last_direction
	bullet.direction = last_direction
	get_tree().current_scene.add_child(bullet)
