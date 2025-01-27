extends Node

func explode(area:Area3D) -> void:
	if area.has_method("projectile_damage"):
		if (area.type=="Rocket" or area.type=="rocket"):
			var expl = Items.explosion.instantiate()
			get_parent().add_child(expl)
			expl.fired_by_player = area.fired_by_player
			expl.global_transform.origin = area.global_transform.origin
		area.queue_free()

func _on_floor_area_entered(area: Area3D) -> void:
	explode(area)

func _on_ceiling_area_entered(area: Area3D) -> void:
	explode(area)

func _on_wall_neg_z_area_entered(area: Area3D) -> void:
	explode(area)

func _on_wall_pos_z_area_entered(area: Area3D) -> void:
	explode(area)

func _on_wall_neg_x_area_entered(area: Area3D) -> void:
	explode(area)

func _on_wall_pos_x_area_entered(area: Area3D) -> void:
	explode(area)
