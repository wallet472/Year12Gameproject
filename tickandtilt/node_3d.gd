extends CharacterBody3D

@export_group("Movement")
@export var forward_speed := 2.0   # Constant forward speed
@export var lateral_speed := 5.0   # Left/right speed
@export var acceleration := 20.0   # Movement smoothing
@export var jump_force := 5.0      # Jump strength
@export var gravity := 9.8         # Gravity strength

@onready var _camera: Camera3D = %Camera3D
@onready var _skin: Node3D = %testguy
@onready var anim: AnimationPlayer = $testguy/AnimationPlayer
var health = 100
@onready var health_bar: ProgressBar = $CameraPivot/Camera3D/HealthBar


# Camera offset (behind and slightly above player)
var _camera_offset := Vector3(0, 2, 5)

func _ready() -> void:
	# Optional: Hide mouse cursor
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	health_bar.value = health
func hurt(hit_points):
	if hit_points < health: 
		health -= hit_points
	else: 
		health = 0
	$CameraPivot/Camera3D/ProgressBar.value = health 
	if health == 0: 
		die()
		
		
func die():
	print("DIE")
	health -= 20
	health_bar.value = health
	





func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		# Jump input
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_force

	# Get forward direction (negative Z-axis, Godot's forward)
	var forward := global_transform.basis.z.normalized()
	var right := global_transform.basis.x.normalized()

	# Constant forward movement
	var move_direction := forward * forward_speed
	# Add lateral movement (left/right)
	var lateral_input := Input.get_axis("move_left", "move_right")
	move_direction += right * lateral_input * lateral_speed

	# Preserve y velocity for gravity/jump
	var y_velocity := velocity.y
	# Update x and z velocities with smoothing
	velocity.x = move_toward(velocity.x, move_direction.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, move_direction.z, acceleration * delta)
	velocity.y = y_velocity

	# Apply movement
	move_and_slide()

	# Update camera position (follow player from behind)
	#_camera.global_position = global_position + _camera_offset
	#_camera.look_at(global_position, Vector3.UP)

	# Animation
	var ground_speed := Vector2(velocity.x, velocity.z).length()
	if ground_speed > 0.0:
		anim.play("local/walk_with_bomb", 0.2)
	else:
		anim.play("local/idle_with_bomb", 0.2)
	if not is_on_floor():
		anim.play("jump", 0.2)
