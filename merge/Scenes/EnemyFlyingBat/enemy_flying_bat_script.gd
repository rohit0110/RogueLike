extends CharacterBody2D

enum State { WANDER, CHASE, HOVER, DIVE, RETURN }

# Movement variables
const CHASE_SPEED = 250.0
const WANDER_SPEED = 50.0
const DIVE_SPEED = 350.0

# Combat variables
const HOVER_HEIGHT = 80.0
const HOVER_RADIUS = 25.0

# State variables
var current_state: State = State.WANDER
var player_is_visible: bool = false
var player: CharacterBody2D = null
var random_direction: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var is_knocked_back: bool = false

# Node references
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_zone: Area2D = $DetectionZone
@onready var direction_timer: Timer = $DirectionTimer
@onready var chase_timer: Timer = $ChaseTimer
@onready var attack_timer: Timer = $AttackTimer
@onready var dive_timer: Timer = $DiveTimer

#HPbar
@onready var healthbar = $HealthBar


func _ready() -> void:
	player = get_node_or_null("/root/Main/Player")
	direction_timer.wait_time = randf_range(1.0, 2.5)
	direction_timer.start()
	_on_direction_timer_timeout()
	animated_sprite.play("fly")
	healthbar.init_health(5)


func _physics_process(delta: float) -> void:
	# Skip normal AI if knocked back
	if is_knocked_back:
		move_and_slide()
		update_animation()
		return

	# --- Global State Transitions ---
	var was_visible = player_is_visible
	player_is_visible = _is_player_in_los()

	if player_is_visible:
		chase_timer.stop()
		if current_state == State.WANDER:
			current_state = State.CHASE
	elif was_visible and not player_is_visible:
		if chase_timer.is_stopped():
			chase_timer.start()

	# --- State Machine ---
	match current_state:
		State.WANDER:
			_wander_state()
		State.CHASE:
			_chase_state()
		State.HOVER:
			_hover_state()
		State.DIVE:
			_dive_state()
		State.RETURN:
			_return_state()

	move_and_slide()
	update_animation()

# --- State Implementations ---

func _wander_state():
	velocity = random_direction * WANDER_SPEED

func _chase_state():
	if not player: return
	target_position = Vector2(player.global_position.x, player.global_position.y - HOVER_HEIGHT)
	velocity = global_position.direction_to(target_position) * CHASE_SPEED
	
	if global_position.distance_to(target_position) < HOVER_RADIUS:
		current_state = State.HOVER
		attack_timer.wait_time = randf_range(1.0, 2.0) # Time before first attack
		attack_timer.start()

func _hover_state():
	if not player: return
	target_position = Vector2(player.global_position.x, player.global_position.y - HOVER_HEIGHT)
	# Gently move towards hover position
	velocity = global_position.direction_to(target_position) * WANDER_SPEED
	
	# Don't move if already there
	if global_position.distance_to(target_position) < 5.0:
		velocity = Vector2.ZERO

func _dive_state():
	velocity = global_position.direction_to(target_position) * DIVE_SPEED

func _return_state():
	if not player: return
	target_position = Vector2(player.global_position.x, player.global_position.y - HOVER_HEIGHT)
	velocity = global_position.direction_to(target_position) * CHASE_SPEED
	
	if global_position.distance_to(target_position) < HOVER_RADIUS:
		current_state = State.HOVER
		attack_timer.wait_time = randf_range(1.5, 3.0) # Time before next attack
		attack_timer.start()

# --- Signal Connections ---

func _is_player_in_los() -> bool:
	if not player: return false
	var bodies_in_zone = detection_zone.get_overlapping_bodies()
	if not player in bodies_in_zone: return false
	var space_state = get_world_2d().direct_space_state
	var exclude_list = [self, player]
	var query = PhysicsRayQueryParameters2D.create(global_position, player.global_position, 1, exclude_list)
	var result = space_state.intersect_ray(query)
	return result.is_empty()

func _on_direction_timer_timeout() -> void:
	if current_state == State.WANDER:
		random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		direction_timer.wait_time = randf_range(1.0, 2.5)
		direction_timer.start()

func _on_chase_timer_timeout() -> void:
	current_state = State.WANDER

func _on_attack_timer_timeout() -> void:
	if current_state == State.HOVER and player:
		current_state = State.DIVE
		target_position = player.global_position # Target the player's current position for the dive
		dive_timer.start()

func _on_dive_timer_timeout() -> void:
	if current_state == State.DIVE:
		current_state = State.RETURN

func update_animation() -> void:
	animated_sprite.play("fly")
	if abs(velocity.x) > 0.1:
		animated_sprite.flip_h = velocity.x < 0

func take_damage(amount: int, knockback_direction: Vector2) -> void:
	# Apply damage to health bar
	healthbar.health -= amount

	# Apply knockback (flying enemies are pushed back more dramatically)
	var knockback_force = 300.0
	velocity = knockback_direction.normalized() * knockback_force

	# Set knockback flag to prevent AI from overriding velocity
	is_knocked_back = true

	# Interrupt current action - reset to wander state
	current_state = State.WANDER
	chase_timer.stop()
	attack_timer.stop()
	dive_timer.stop()

	# Reset knockback flag after short duration
	await get_tree().create_timer(0.3).timeout
	is_knocked_back = false

	# Restart wander behavior
	direction_timer.wait_time = randf_range(1.0, 2.5)
	direction_timer.start()
