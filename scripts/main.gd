extends Node3D

@export var enemy_scene : PackedScene
@export var x_offset : float = 20.0
@export var y_offset : float = 1.0
@export var z_offset : float = 20.0
@export var spread_offset : float = 1.5

func _ready() -> void:
	spawn_wave(5)

# n will be squared
func spawn_wave(n:int) -> void:
	for i in n:
		for j in n:
			var enemy = enemy_scene.instantiate()
			add_child(enemy)
			enemy.global_transform.origin = Vector3(
				i * spread_offset + x_offset,
				y_offset, 
				j * spread_offset + z_offset
			)
