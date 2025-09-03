extends CharacterBody2D

class_name ToechondriaEnemy

const speed = 100
const random_speed = 40
const gravity = 900.0
const jump_force = -400.0
const STOPPING_DISTANCE = 28.0 * 2 # Player width (28) + margin
const TOO_CLOSE_DISTANCE = 28.0 * 1.5 # Don't let the player get closer than this

var is_chasing: bool = false
var player: CharacterBody2D = null
var random_direction: Vector2 = Vector2.ZERO
var player_is_visible: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var obstacle_detector: RayCast2D = $ObstacleDetector
@onready var detection_zone: Area2D = $DetectionZone
@onready var chase_timer: Timer = $ChaseTimer
@onready var unstuck_cooldown: Timer = $UnstuckCooldown
@onready var retreat_timer: Timer = $RetreatDelayTimer

func _ready() -> void:
	# Find the player node. This assumes your main scene is named "Main"
	# and the player node is named "Player".
	var player_node = get_node_or_null("/root/Main/Player")
	if player_node is CharacterBody2D:
		player = player_node
	
	# Configure and start the timer for random movement
	$DirectionTimer.wait_time = 2 # Change direction every 2 seconds
	$DirectionTimer.start()

	retreat_timer.wait_time = 1 # 1 seconds
	retreat_timer.one_shot = true

	
	# Initial random direction
	_on_direction_timer_timeout()

	if animated_sprite.sprite_frames.has_animation("jump"):
		animated_sprite.sprite_frames.set_animation_loop("jump", false)

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# --- AI State Logic ---
	var was_visible = player_is_visible
	player_is_visible = _is_player_in_los()

	if player_is_visible:
		is_chasing = true
		chase_timer.stop()
	elif was_visible and not player_is_visible: # If player was just lost
		chase_timer.start()
	# -------------------

	# --- Movement & AI Decision Logic ---
	if unstuck_cooldown.is_stopped(): # Only process AI if not in a cooldown state
		# --- Horizontal Movement ---
		if is_chasing and player:
			var vector_to_player = player.global_position - global_position
			var x_dist = abs(vector_to_player.x)
			var y_dist = abs(vector_to_player.y)

			# --- Verticality Check ---
			if y_dist < 50: # On the same level
				# 1a: Player is too close, start retreat timer.
				if x_dist < TOO_CLOSE_DISTANCE and is_on_floor():
					if retreat_timer.is_stopped():
						retreat_timer.start()
				# 1b: Player is in the sweet spot, stop.
				elif x_dist < STOPPING_DISTANCE:
				# Player backed away, cancel the retreat timer
					if not retreat_timer.is_stopped():
						retreat_timer.stop()
					velocity.x = 0
				# 1c: Player is too far, move closer.
				else:
					# Player backed away, cancel the retreat timer
					if not retreat_timer.is_stopped():
						retreat_timer.stop()
					velocity.x = sign(vector_to_player.x) * speed
			else: # On a different level
				# Stuck on top check: Jump if player is standing on a platform right above.
				if player.is_on_floor() and x_dist < 5.0 and is_on_floor():
					velocity.x = [speed, -speed][randi() % 2]
					velocity.y = jump_force
					unstuck_cooldown.start()
				# Normal chase
				else:
					velocity.x = sign(vector_to_player.x) * speed
		else:
			velocity.x = random_direction.x * random_speed
		
		# --- Obstacle Jump Logic ---
		if is_chasing and player and velocity.x != 0:
			obstacle_detector.target_position.x = sign(velocity.x) * 20
			obstacle_detector.force_raycast_update()
			if is_on_floor() and obstacle_detector.is_colliding():
				velocity.y = jump_force
	# -------------------

	move_and_slide()
	update_animation()

func _is_player_in_los() -> bool:
	if not player:
		return false

	# 1. Check if player is inside the vision cone shape
	var bodies_in_cone = detection_zone.get_overlapping_bodies()
	if not player in bodies_in_cone:
		return false

	# 2. Raycast to check for obstacles
	var space_state = get_world_2d().direct_space_state
	# Exclude the enemy and the player from the raycast, so we only hit walls
	var exclude_list = [self, player]
	var query = PhysicsRayQueryParameters2D.create(global_position, player.global_position, 1, exclude_list)
	var result = space_state.intersect_ray(query)

	# If the result is empty, it means the ray didn't hit any obstacles. Line of sight is clear.
	return result.is_empty()

func _on_direction_timer_timeout() -> void:
	# Generate a new random direction
	if not (is_chasing and player):
		random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

func update_animation() -> void:
	# Set animation based on velocity (walk/idle/jump)
	if is_on_floor():
		if abs(velocity.x) > 10:
			animated_sprite.play("walk")
		else:
			animated_sprite.play("idle")
	else:
		animated_sprite.play("jump")

	# Set direction based on player position (if chasing) or velocity (if wandering)
	if is_chasing and player:
		var vector_to_player = player.global_position - global_position
		# Only flip if the player is meaningfully to the left or right
		if abs(vector_to_player.x) > 1.0:
			var direction = sign(vector_to_player.x)
			animated_sprite.flip_h = direction < 0
			detection_zone.scale.x = direction
	elif velocity.x != 0:
		# Fallback to velocity for non-chasing movement
		var direction = sign(velocity.x)
		animated_sprite.flip_h = direction < 0
		detection_zone.scale.x = direction

func _on_chase_timer_timeout() -> void:
	is_chasing = false

func _on_retreat_delay_timer_timeout() -> void:
	# Before hopping, double-check if the player is still too close.
	# This prevents hopping if the player moved away while the timer was ticking.
	if player and is_on_floor():
		var vector_to_player = player.global_position - global_position
		if abs(vector_to_player.x) < TOO_CLOSE_DISTANCE:
			_execute_retreat_hop()

func _execute_retreat_hop() -> void:
	var vector_to_player = player.global_position - global_position
	velocity.x = -sign(vector_to_player.x) * speed # Hop away
	velocity.y = jump_force
	unstuck_cooldown.start()
