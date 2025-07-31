extends Node3D

@export var roadsegment: Array[PackedScene] = []
var amnt = 10
var rng = RandomNumberGenerator.new()
var offset = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	for n in amnt:
		spawnmodule(n*offset)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawnmodule(n):
	rng.randomize()
	var num = rng.randi_range(0,roadsegment.size()-1)
	var instance =roadsegment[num].instantiate()
	instance.position.x = n
	add_child(instance)
