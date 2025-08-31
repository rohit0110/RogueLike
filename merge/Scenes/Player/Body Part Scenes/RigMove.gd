extends CharacterBody2D

# ---- tuning ----
@export var speed: float = 180.0
@export var accel: float = 2000.0
@export var friction: float = 1800.0
@export var anim_fps: float = 5.0
var anim: String = "Idle"
var t: float = 0.0

# ---- scene refs ----
@onready var rig: Node2D        = $Rig
@onready var head_slot: Node2D  = $Rig/Head
@onready var torso_slot: Node2D = $Rig/Torso
@onready var lhand_slot: Node2D = $Rig/LeftHand
@onready var rhand_slot: Node2D = $Rig/RightHand
@onready var lleg_slot: Node2D  = $Rig/LeftLeg
@onready var rleg_slot: Node2D  = $Rig/RightLeg


func _physics_process(delta: float) -> void:
	# input
	var dir: float = Input.get_axis("move_left","move_right")

	# horizontal velocity
	var target: float = dir * speed
	velocity.x = move_toward(velocity.x, target, (accel if dir != 0.0 else friction) * delta)

	# no vertical/jump for this minimal build
	move_and_slide()

	# face direction
	if dir != 0.0: rig.scale.x = (-1.0 if dir < 0.0 else 1.0)

	# state: idle vs walk
	var new_anim: String = ("Walk" if abs(velocity.x) > .1 else "Idle")
	if new_anim != anim:
		anim = new_anim
		t = 0.0

	# single clock
	t += delta
	var frame_idx: int = int(floor(t * anim_fps))

	# drive six parts
	for p: Part in _parts():
		p.set_anim(anim)
		p.set_frame(frame_idx, anim)

func _parts() -> Array[Part]:
	var out: Array[Part] = []
	var slots: Array[Node2D] = [head_slot, torso_slot, lhand_slot, rhand_slot, lleg_slot, rleg_slot]
	for s: Node2D in slots:
		if s and s.get_child_count() > 0:
			var p: Part = s.get_child(0) as Part
			if p: out.append(p)
	return out
