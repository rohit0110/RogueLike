extends Area2D

@export var speed : int = 1000
var direction 

func _process(delta):
	position.x += direction * speed * delta
 
