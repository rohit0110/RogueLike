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

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var obstacle_detector: RayCast2D = $ObstacleDetector

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

	if is_chasing and player:
		var vector_to_player = player.global_position - global_position
		if abs(vector_to_player.x) > STOPPING_DISTANCE:
			velocity.x = sign(vector_to_player.x) * speed
		else:
			velocity.x = 0
	else:
		velocity.x = random_direction.x * random_speed
	
	# Obstacle detection and jump logic
	if is_chasing and player and velocity.x != 0:
		obstacle_detector.target_position.x = sign(velocity.x) * 20
		obstacle_detector.force_raycast_update()
		if is_on_floor() and obstacle_detector.is_colliding():
			if player.global_position.y < global_position.y - 10: # Jump if player is above
				velocity.y = jump_force

	move_and_slide()
	update_animation()

func _on_direction_timer_timeout() -> void:
	# Generate a new random direction
	if not (is_chasing and player):
		random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

func update_animation() -> void:
	if is_on_floor():
		if abs(velocity.x) > 10:
			animated_sprite.play("walk")
		else:
			animated_sprite.play("idle")
	else:
		animated_sprite.play("jump")

	if velocity.x != 0:
		animated_sprite.flip_h = velocity.x < 0

func _on_detection_zone_body_entered(body: Node) -> void:
	if body == player:
		is_chasing = true

func _on_detection_zone_body_exited(body: Node) -> void:
	if body == player:
		is_chasing = false
