extends CharacterBody3D

@export_group("Movement")
@export var lateral_speed := 5.0   # Left/right speed
@export var acceleration := 20.0   # Movement smoothing
@export var jump_force := 3.4      # Jump strength
@export var gravity := 9.8         # Gravity strength

@onready var anim: AnimationPlayer = $testguy/AnimationPlayer
var health = 200
@onready var health_bar: ProgressBar = $CameraPivot/Camera3D/HealthBar


func _ready() -> void:
	# Hide mouse cursor
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

	# Get right direction (Godot's x-axis)
	var right := global_transform.basis.x.normalized()

	# Lateral movement (left/right)
	var lateral_input := Input.get_axis("move_left", "move_right")
	var move_direction := right * lateral_input * lateral_speed

	# Preserve y velocity for gravity/jump
	var y_velocity := velocity.y
	# Update x velocity with smoothing
	velocity.x = move_toward(velocity.x, move_direction.x, acceleration * delta)
	velocity.z = 0.0  # Prevent movement in z-axis
	velocity.y = y_velocity

	# Apply movement
	move_and_slide()

	# Animation: Prioritize jump when airborne
	if not is_on_floor():
		anim.play("jump", 0.2)
	else:
		var ground_speed = abs(velocity.x)
		if ground_speed > 0.0:
			anim.play("local/walk_with_bomb", 0.2)
		else:
			anim.play("local/idle_with_bomb", 0.2)
