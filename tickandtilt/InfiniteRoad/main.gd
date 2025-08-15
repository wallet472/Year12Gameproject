extends Node3D

# Export variables for easy customization
@export var road_scenes: Array[PackedScene] = []
@export var car_scene: PackedScene  # Add car scene export
@export var road_speed: float = 10.0
@export var car_speed: float = 12.0  # Slightly faster than road for relative movement
@export var road_segment_length: float = 6.0
@export var spawn_z_position: float = 120.0
@export var delete_z_position: float = -6.0
@export var initial_road_count: int = 20
@export var car_spawn_probability: float = 0.3  # Chance to spawn a car per road segment
@export var lane_positions: Array[float] = [-2.0, 0.0, 2.0]  # Possible X positions for cars

# Internal variables
var active_roads: Array[Node3D] = []
var active_cars: Array[Node3D] = []  # Track active cars
var next_spawn_z: float
var rng = RandomNumberGenerator.new()

func _ready():
	# Validate inputs
	if road_scenes.is_empty():
		push_error("No road scenes assigned to road_scenes array!")
		return
	if car_scene == null:
		push_error("No car scene assigned!")
		return
	
	# Initialize RNG and spawn position
	rng.randomize()
	next_spawn_z = spawn_z_position
	
	# Generate initial roads
	generate_initial_roads()

func _process(delta):
	# Move all active roads and cars
	move_roads(delta)
	move_cars(delta)
	
	# Clean up roads and cars
	cleanup_roads()
	cleanup_cars()
	
	# Spawn new roads and cars
	spawn_new_roads()

func generate_initial_roads():
	# First spawn a road at position 0 to avoid gap at start
	spawn_road_at_position(0.0)
	
	# Then spawn the rest of the initial roads
	for i in range(initial_road_count):
		var z_pos = next_spawn_z - (i * road_segment_length)
		spawn_road_at_position(z_pos)
		# Spawn initial cars with probability
		if rng.randf() < car_spawn_probability:
			spawn_car_at_position(z_pos)

func spawn_road_at_position(z_pos: float):
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

func spawn_car_at_position(z_pos: float):
	if car_scene == null:
		return
	
	# Instantiate car
	var car_instance = car_scene.instantiate()
	
	# Random lane position
	var lane_x = lane_positions[randi() % lane_positions.size()]
	
	# Position the car (slightly above road to avoid collision issues)
	car_instance.position = Vector3(lane_x, 0.5, z_pos)
	
	# Add to scene and track it
	add_child(car_instance)
	active_cars.append(car_instance)

func move_roads(delta: float):
	for road in active_roads:
		if is_instance_valid(road):
			road.position.z -= road_speed * delta

func move_cars(delta: float):
	for car in active_cars:
		if is_instance_valid(car):
			# Move cars toward player (same direction as road, but possibly faster/slower)
			car.position.z -= car_speed * delta

func cleanup_roads():
	var roads_to_remove: Array[Node3D] = []
	for road in active_roads:
		if is_instance_valid(road) and road.position.z < delete_z_position:
			roads_to_remove.append(road)
	
	for road in roads_to_remove:
		active_roads.erase(road)
		road.queue_free()

func cleanup_cars():
	var cars_to_remove: Array[Node3D] = []
	for car in active_cars:
		if is_instance_valid(car) and car.position.z < delete_z_position:
			cars_to_remove.append(car)
	
	for car in cars_to_remove:
		active_cars.erase(car)
		car.queue_free()

func spawn_new_roads():
	var furthest_z = delete_z_position
	for road in active_roads:
		if is_instance_valid(road) and road.position.z > furthest_z:
			furthest_z = road.position.z
	
	# Spawn roads and cars if needed
	while furthest_z < spawn_z_position:
		furthest_z += road_segment_length
		spawn_road_at_position(furthest_z)
		# Spawn car with probability
		if rng.randf() < car_spawn_probability:
			spawn_car_at_position(furthest_z)

func get_road_count() -> int:
	return active_roads.size()

func get_car_count() -> int:
	return active_cars.size()

func set_road_speed(new_speed: float):
	road_speed = new_speed

func set_car_speed(new_speed: float):
	car_speed = new_speed

func clear_all_roads_and_cars():
	for road in active_roads:
		if is_instance_valid(road):
			road.queue_free()
	for car in active_cars:
		if is_instance_valid(car):
			car.queue_free()
	active_roads.clear()
	active_cars.clear()
	next_spawn_z = spawn_z_position

func restart_generation():
	clear_all_roads_and_cars()
	# Wait one frame for cleanup
	await get_tree().process_frame
	generate_initial_roads()
