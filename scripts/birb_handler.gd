extends Node3D

@onready var birb = %Birb

var birb_speed:float = 0.5
var is_clockwise:bool = true
var direction:float = -1.0
var time := 0.0
var time_offset := 0.0

func _ready() -> void:
	birb.transform.origin.x = randf_range(20.0, 70.0)
	birb_speed = randf_range(0.4, 0.7)
	birb.flap_speed = randf_range(9,12)
	time_offset = randf_range(0,10000)
	
func _physics_process(delta: float) -> void:
	time += delta
	rotation_degrees.y += birb_speed * direction
	rotation_degrees.x = perlin(time + time_offset) * 5

func set_is_clockwise(clockwise:bool) -> void:
	is_clockwise = clockwise
	direction = -(float(is_clockwise) * 2 - 1)

func perlin(x:float) -> float:
	return sin(2 * x) + sin(PI * x)
