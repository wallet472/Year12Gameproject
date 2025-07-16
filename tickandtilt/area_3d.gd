extends Area3D

@onready var anim: AnimationPlayer = $"../AnimationPlayer"

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		anim.play("Building_fall")
