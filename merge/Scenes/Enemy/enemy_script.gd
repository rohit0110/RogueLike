extends CharacterBody2D

class_name ToechondriaEnemy

const speed = 100
const random_speed = 40
const gravity = 900.0
const jump_force = -400.0
const STOPPING_DISTANCE = 28.0 * 2 # Player width (28) + margin

var is_chasing: bool = false
var player: CharacterBody2D = null
var random_direction: Vector2 = Vector2.ZERO
var player_is_visible: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var obstacle_detector: RayCast2D = $ObstacleDetector
@onready var detection_zone: Area2D = $DetectionZone
@onready var chase_timer: Timer = $ChaseTimer
@onready var unstuck_cooldown: Timer = $UnstuckCooldown

func _ready() -> void:
	# Find the player node. This assumes your main scene is named "Main"
	# and the player node is named "Player".
	var player_node = get_node_or_null("/root/Main/Player")
	if player_node is CharacterBody2D:
		player = player_node
	
	# Configure and start the timer for random movement
	$DirectionTimer.wait_time = 2 # Change direction every 2 seconds
	$DirectionTimer.start()
	
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
	if unstuck_cooldown.is_stopped(): # Only process AI if not in the unstuck hop
		# --- Horizontal Movement ---
		if is_chasing and player:
			var vector_to_player = player.global_position - global_position
			
			# Condition 1: On same level and close enough to stop.
			if abs(vector_to_player.y) < 50 and abs(vector_to_player.x) < STOPPING_DISTANCE:
				velocity.x = 0
			# Condition 2: Stuck on top of the player. Hop only triggers if on a surface.
			elif abs(vector_to_player.y) > 50 and abs(vector_to_player.x) < 5.0 and is_on_floor():
				velocity.x = [speed, -speed][randi() % 2] # Hop randomly left or right
				velocity.y = jump_force
				unstuck_cooldown.start() # Disable AI for a moment
			# Condition 3: Normal chase.
			else:
				velocity.x = sign(vector_to_player.x) * speed
		else:
			# Condition 4: Wander.
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
