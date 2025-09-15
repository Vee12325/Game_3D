extends CharacterBody3D

# Minimum speed of the mob in meters per second.
@export var min_speed = 8
# Maximum speed of the mob in meters per second.
@export var max_speed = 15
signal squashed

var anim_player: AnimationPlayer

func _ready():
	# หา AnimationPlayer ที่อยู่ใน scene tree ของ mob
	anim_player = find_child("AnimationPlayer", true, false)
	if anim_player:
		anim_player.play("CharacterArmature|Flying_Idle")
	else:
		push_error("❌ AnimationPlayer not found in mob scene!")

func _physics_process(_delta):
	move_and_slide()

# This function will be called from the Main scene.
func initialize(start_position, player_position):
	# We position the mob by placing it at start_position
	# and rotate it towards player_position, so it looks at the player.
	look_at_from_position(start_position, player_position, Vector3.UP)
	# Rotate this mob randomly within range of -45 and +45 degrees,
	# so that it doesn't move directly towards the player.
	rotate_y(randf_range(-PI / 4, PI / 4))
	
	var random_speed = randi_range(min_speed, max_speed)
	# We calculate a forward velocity that represents the speed.
	velocity = Vector3.FORWARD * random_speed
	# We then rotate the velocity vector based on the mob's Y rotation
	# in order to move in the direction the mob is looking.
	velocity = velocity.rotated(Vector3.UP, rotation.y)

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	queue_free()
	
func squash():
	if anim_player:
		anim_player.play("CharacterArmature|Death")
		await anim_player.animation_finished
	squashed.emit()
	queue_free()
