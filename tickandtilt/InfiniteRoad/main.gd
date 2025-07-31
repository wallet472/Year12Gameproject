extends Node3D

# Export variables for easy customization
@export var road_scenes: Array[PackedScene] = []
@export var road_speed: float = 10.0
@export var road_segment_length: float = 6.0
@export var spawn_z_position: float = 120.0
@export var delete_z_position: float = -6.0
@export var initial_road_count: int = 20

# Internal variables
var active_roads: Array[Node3D] = []
var next_spawn_z: float

func _ready():
	# Validate that we have road scenes
	if road_scenes.is_empty():
		push_error("No road scenes assigned to road_scenes array!")
		return
	
	# Initialize spawn position
	next_spawn_z = spawn_z_position
	
	# Generate initial roads
	generate_initial_roads()

func _process(delta):
	# Move all active roads
	move_roads(delta)
	
	# Check for roads that need to be deleted
	cleanup_roads()
	
	# Spawn new roads if needed
	spawn_new_roads()

func generate_initial_roads():
	"""Generate the initial set of roads at startup"""
	# First spawn a road at position 0 to avoid gap at start
	spawn_road_at_position(0.0)
	
	# Then spawn the rest of the initial roads
	for i in range(initial_road_count):
		spawn_road_at_position(next_spawn_z - (i * road_segment_length))

func spawn_road_at_position(z_pos: float):
	"""Spawn a road segment at a specific Z position"""
	if road_scenes.is_empty():
		return
	
	# Pick a random road scene
	var random_scene = road_scenes[randi() % road_scenes.size()]
	var road_instance = random_scene.instantiate()
	
	# Position the road
	road_instance.position = Vector3(0, 0, z_pos)
	
	# Add to scene and track it
	add_child(road_instance)
	active_roads.append(road_instance)

func move_roads(delta: float):
	"""Move all active roads towards the player"""
	for road in active_roads:
		if is_instance_valid(road):
			# Move road towards player (negative Z direction)
			road.position.z -= road_speed * delta

func cleanup_roads():
	"""Remove roads that have passed behind the player"""
	var roads_to_remove: Array[Node3D] = []
	
	for road in active_roads:
		if is_instance_valid(road) and road.position.z < delete_z_position:
			roads_to_remove.append(road)
	
	# Remove roads that are behind the player
	for road in roads_to_remove:
		active_roads.erase(road)
		road.queue_free()

func spawn_new_roads():
	"""Spawn new roads to maintain continuous generation"""
	# Find the furthest road's Z position
	var furthest_z = delete_z_position
	for road in active_roads:
		if is_instance_valid(road) and road.position.z > furthest_z:
			furthest_z = road.position.z
	
	# Spawn roads if we need more in front
	while furthest_z < spawn_z_position:
		furthest_z += road_segment_length
		spawn_road_at_position(furthest_z)

func get_road_count() -> int:
	"""Get the current number of active roads"""
	return active_roads.size()

func set_road_speed(new_speed: float):
	"""Dynamically change the road speed"""
	road_speed = new_speed

func clear_all_roads():
	"""Remove all active roads (useful for restarting)"""
	for road in active_roads:
		if is_instance_valid(road):
			road.queue_free()
	active_roads.clear()
	next_spawn_z = spawn_z_position

func restart_generation():
	"""Clear all roads and regenerate from scratch"""
	clear_all_roads()
	# Wait one frame for cleanup
	await get_tree().process_frame
	generate_initial_roads()  
