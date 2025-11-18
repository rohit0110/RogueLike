extends Node2D
class_name Part

@onready var anim_player = $AnimationPlayer


func play_attack() -> void:
	anim_player.play("attack")
