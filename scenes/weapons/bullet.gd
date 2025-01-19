extends Node3D

const SPEED = 40.0

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D

func _ready():
	$Life.start()
	pass
	
func _process(delta):
	position += transform.basis * Vector3(0, -SPEED, 0) * delta


# Despawn the bullet after some time
func _on_life_timeout() -> void:
	queue_free()
