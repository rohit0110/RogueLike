extends Area2D

@export var speed : int = 1000
var direction : Vector2

func _ready() -> void:
	var player : CharacterBody2D = get_tree().get_first_node_in_group("player")
	scale = player.scale
	rotation = direction.angle()
	


func _process(delta):
	position += direction * speed * delta
 
