extends Node2D

@export var animation_tree : AnimationTree
@export var damage : int = 1
var playback: AnimationNodeStateMachinePlayback
var attack_state : bool = false
var has_dealt_damage : bool = false
var original_rotation = rotation
var enemies_in_range : Array = []
@onready var anim = $AnimationPlayer
@onready var hitbox : Area2D = $Rotation/Sprite2D/Area2D

func _ready() -> void:
	playback = animation_tree["parameters/playback"]

	# Connect hitbox signals
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	hitbox.body_exited.connect(_on_hitbox_body_exited)

func trigger_attack() -> void:
	if not attack_state:
		var angle_to_turn : float = get_local_mouse_position().angle()
		if rad_to_deg(angle_to_turn) > 75:
			angle_to_turn = deg_to_rad(75)
		elif rad_to_deg(angle_to_turn) < -75:
			angle_to_turn = deg_to_rad(-75)
		$Rotation.rotation = angle_to_turn
		attack_state = true
		has_dealt_damage = false  # Reset damage flag for new attack
		playback.travel("attack")
		# Delay damage until hitbox is active (animation enables it at ~0.125s)
		_schedule_damage()
		# Start cooldown timer
		_start_attack_cooldown()

func _schedule_damage() -> void:
	# Wait for hitbox to become active in animation
	await get_tree().create_timer(0.125).timeout

	# Check for enemies multiple times during the active swing window
	var check_duration = 0.2  # How long to check (0.125s to 0.325s)
	var check_interval = 0.05  # Check every 50ms
	var time_elapsed = 0.0

	while time_elapsed < check_duration and not has_dealt_damage:
		if enemies_in_range.size() > 0:
			_deal_damage_to_enemies()
			has_dealt_damage = true
			break
		await get_tree().create_timer(check_interval).timeout
		time_elapsed += check_interval

func _start_attack_cooldown() -> void:
	await get_tree().create_timer(0.5).timeout
	attack_state = false

func _process(_delta: float) -> void:
	select_animation()
	update_animation_parameters()

func select_animation():
	if not attack_state:
		$Rotation.rotation = original_rotation
		if playback:
			playback.travel("idle")

func update_animation_parameters():
	pass				# DIRECTION FOR MOVEMENT ANIMATION

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		enemies_in_range.append(body)

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body in enemies_in_range:
		enemies_in_range.erase(body)

func _deal_damage_to_enemies() -> void:
	# Get direction for knockback
	var facing_direction = 1 if get_parent().get_parent().scale.x > 0 else -1
	var knockback_dir = Vector2(facing_direction, -0.2).normalized()

	# Debug: Print how many enemies are in range
	print("Melee attack! Enemies in range: ", enemies_in_range.size())

	# Damage all enemies currently in hitbox
	for enemy in enemies_in_range:
		if is_instance_valid(enemy) and enemy.has_method("take_damage"):
			print("Dealing ", damage, " damage to enemy")
			enemy.take_damage(damage, knockback_dir)
