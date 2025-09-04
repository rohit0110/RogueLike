extends CharacterBody2D

# Movement variables
const CHASE_SPEED = 200.0
const WANDER_SPEED = 90.0

# State variables
var is_chasing: bool = false
var player_is_visible: bool = false
var player: CharacterBody2D = null
var random_direction: Vector2 = Vector2.ZERO

# Node references
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_zone: Area2D = $DetectionZone
@onready var direction_timer: Timer = $DirectionTimer
@onready var chase_timer: Timer = $ChaseTimer


func _ready() -> void:
	# Attempt to find the player node in the scene tree.
	player = get_node_or_null("/root/Main/Player")

	# --- Timer Setup ---
	direction_timer.wait_time = randf_range(1.0, 2.5)
	direction_timer.start()

	# Set initial state
	_on_direction_timer_timeout()
	animated_sprite.play("fly")


func _physics_process(delta: float) -> void:
	# --- State Logic ---
	var was_visible = player_is_visible
	player_is_visible = _is_player_in_los()

	if player_is_visible:
		is_chasing = true
		chase_timer.stop()
	elif was_visible and not player_is_visible: # Player was just lost
		chase_timer.start()

	# --- Movement Logic ---
	if is_chasing and player:
		# Chase the player
		var vector_to_player = player.global_position - global_position
		velocity = vector_to_player.normalized() * CHASE_SPEED
	else:
		# Wander randomly
		velocity = random_direction * WANDER_SPEED
	
	move_and_slide()
	update_animation()


func _is_player_in_los() -> bool:
	if not player:
		return false

	# 1. Check if player is inside the broad detection area
	var bodies_in_zone = detection_zone.get_overlapping_bodies()
	if not player in bodies_in_zone:
		return false

	# 2. Raycast to check for obstacles (walls) between the bat and the player
	var space_state = get_world_2d().direct_space_state
	# Exclude the enemy and the player from the raycast to only detect walls
	var exclude_list = [self, player]
	var query = PhysicsRayQueryParameters2D.create(global_position, player.global_position, 1, exclude_list)
	var result = space_state.intersect_ray(query)

	# If the result is empty, the ray didn't hit any obstacles. Line of sight is clear.
	return result.is_empty()


func _on_direction_timer_timeout() -> void:
	# Generate a new random direction for wandering
	random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	# Set a new random time for the next change
	direction_timer.wait_time = randf_range(1.0, 2.5)
	direction_timer.start()


func _on_chase_timer_timeout() -> void:
	# Stop chasing after the timer runs out
	is_chasing = false


func update_animation() -> void:
	# The bat is always flying
	animated_sprite.play("fly")

	# Flip sprite based on horizontal velocity to face the direction of movement
	if abs(velocity.x) > 0.1:
		animated_sprite.flip_h = velocity.x < 0
