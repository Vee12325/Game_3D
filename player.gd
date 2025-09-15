extends CharacterBody3D

@export var speed: float = 14.0
@export var fall_acceleration: float = 75.0
@export var jump_impulse: float = 20.0
@export var bounce_impulse: float = 16.0

signal hit

var target_velocity: Vector3 = Vector3.ZERO
var anim_player: AnimationPlayer

func _ready() -> void:
	anim_player = find_child("AnimationPlayer", true, false)
	_play_anim("Armature|Idle")

func _physics_process(delta: float) -> void:
	var direction: Vector3 = Vector3.ZERO

	# Movement Input
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1

	# Normalize + Rotate Character
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Pivot.look_at(global_transform.origin + direction, Vector3.UP)

	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# Jump / Walk / Idle Animation
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse
		_play_anim("Armature|Jump")
	elif direction != Vector3.ZERO and is_on_floor():
		_play_anim("Armature|Walk")
	elif is_on_floor():
		_play_anim("Armature|Idle")

	# Gravity
	if not is_on_floor():
		target_velocity.y -= fall_acceleration * delta

	# Movement
	velocity = target_velocity
	move_and_slide()

	# Collision check
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider() == null:
			continue

		if collision.get_collider().is_in_group("mob"):
			var mob = collision.get_collider()
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				mob.squash()
				target_velocity.y = bounce_impulse
				break

func die() -> void:
	hit.emit()
	queue_free()

func _on_mob_detector_body_entered(body: Node3D) -> void:
	die()

# Utility function สำหรับเล่นอนิเมชันโดยไม่ต้องซ้ำ
func _play_anim(name: String) -> void:
	if anim_player and anim_player.current_animation != name:
		anim_player.play(name)
