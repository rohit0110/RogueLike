extends Node2D

@onready var anim = $AnimationPlayer

func play_attack():
	anim.play("attack")
