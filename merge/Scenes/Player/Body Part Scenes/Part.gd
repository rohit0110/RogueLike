extends Node2D
class_name Part
@onready var spr: AnimatedSprite2D = $AnimatedSprite2D
func set_anim(name: String) -> void: if spr.sprite_frames.has_animation(name): spr.play(name)
func set_frame(i: int, anim: String) -> void:
	var n := spr.sprite_frames.get_frame_count(anim)
	if n > 0: spr.frame = i % n
