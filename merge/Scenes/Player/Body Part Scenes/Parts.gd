extends Node2D
class_name Part

@onready var spr: AnimatedSprite2D = $AnimatedSprite2D

# Change animation
func set_anim(name: String) -> void:
	if spr.animation != name and spr.sprite_frames.has_animation(name):
		spr.play(name)

# Set specific frame (used for syncing across parts)
func set_frame(frame_idx: int, anim: String) -> void:
	if spr.sprite_frames.has_animation(anim):
		var frame_count := spr.sprite_frames.get_frame_count(anim)
		if frame_count > 0:
			spr.frame = frame_idx % frame_count

# Override in subclasses if needed
func play_attack() -> void:
	if spr.sprite_frames.has_animation("attack"):
		spr.play("attack")
