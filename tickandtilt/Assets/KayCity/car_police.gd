func _on_hit_player_area_body_entered(body: Node) -> void:
	if body.is_in_group("Bomb"):
		body.hurt(10)
	


func _on_hit_bomb_area_area_entered(area: Area3D) -> void:
	if area.is_in_group("Bomb"):
		area.get_parent().die()
