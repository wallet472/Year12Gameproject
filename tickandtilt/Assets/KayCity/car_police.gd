extends Node3D
@export var car_mesh : Array[Mesh]


	
#func _on_hit_player_area_body_entered(body: Node) -> void:
	#if body.is_in_group("Bomb"):
		#body.hurt(10)
	


func _on_hit_bomb_area_area_entered(area: Area3D) -> void:
	print("ENTERED")
	if area.is_in_group("Bomb"):
		print("IS BOMB")
		area.get_parent().die()


func _on_hit_bomb_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Bomb"):
		body.hurt(10)
