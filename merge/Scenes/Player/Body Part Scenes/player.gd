extends CharacterBody2D
signal hit

@export var speed := 200.0
@export var jump_force := -400.0
@export var gravity := 900.0

var is_jumping := false

func _ready() -> void:
	 #Ensure jump animation does not loop
	if $AnimatedSprite2D.sprite_frames.has_animation("jump"):
		$AnimatedSprite2D.sprite_frames.set_animation_loop("jump", false)

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# Reset vertical velocity when touching ground
		if velocity.y > 0:
			velocity.y = 0

	# Horizontal input
	velocity.x = 0
	if Input.is_action_pressed("move_right"):
		velocity.x += speed
	if Input.is_action_pressed("move_left"):
		velocity.x -= speed

	# Jump input
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
		is_jumping = true
		$AnimatedSprite2D.play("jump")
		$AnimatedSprite2D.frame = 0

	# Animation logic
	if is_jumping:
		# Once jump anim is finished → immediately go idle
		if $AnimatedSprite2D.animation == "jump" and not $AnimatedSprite2D.is_playing():
			$AnimatedSprite2D.play("idle")
			is_jumping = false
	else:
		if is_on_floor():
			if velocity.x != 0:
				$AnimatedSprite2D.play("walk")
				$AnimatedSprite2D.flip_h = velocity.x < 0
			else:
				$AnimatedSprite2D.play("idle")

	# Physics move
	move_and_slide()

# Git test
