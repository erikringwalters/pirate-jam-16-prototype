extends Area3D


func _on_body_entered(body: Node3D) -> void:
	if (!get_parent().held_by_player \
	and body.has_method('player_process_melee_damage') \
	and get_parent().is_pickedup):
		body.player_process_melee_damage(get_parent().damage)
