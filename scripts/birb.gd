extends Node3D

@onready var wing_l = %wingL_flat
@onready var wing_r = %wingR_flat
@onready var tail = %tail

var time := 0.0
var flap_speed := 5.0
var flap_offset := 0.25
var tail_amp := 0.2

func _physics_process(delta: float) -> void:
	time += delta
	wing_l.rotation.z = sin(time*flap_speed) + flap_offset
	wing_r.rotation.z = -wing_l.rotation.z
	#tail.rotation.x = sin(time*flap_speed) * tail_amp
