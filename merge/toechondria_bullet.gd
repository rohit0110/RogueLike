extends Area2D

@export var speed : int = 1000
var direction 

func _ready() -> void:
	var player : CharacterBody2D = get_tree().get_first_node_in_group("player")
	scale = player.scale


func _process(delta):
	position.x += direction * speed * delta
 
