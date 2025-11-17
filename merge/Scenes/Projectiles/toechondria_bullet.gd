extends Area2D

@export var speed : int = 1000
@export var lifetime : float = 5.0
var direction : Vector2
var damage : int = 1

func _ready() -> void:
	var player : CharacterBody2D = get_tree().get_first_node_in_group("player")
	scale = player.scale
	rotation = direction.angle()

	# Connect collision signal
	body_entered.connect(_on_body_entered)

	# Auto-destroy after lifetime expires
	get_tree().create_timer(lifetime).timeout.connect(_on_lifetime_expired)

func _process(delta):
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	# Check if we hit an enemy
	if body.has_method("take_damage"):
		body.take_damage(damage, direction)
		queue_free()  # Destroy projectile after hitting enemy

func _on_lifetime_expired() -> void:
	queue_free()  # Destroy projectile after lifetime expires
