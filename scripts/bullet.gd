extends Area3D

const SPEED : float = 20.0
var damage : float = 10.0
var type : String

@onready var mesh :MeshInstance3D = $MeshInstance3D
@onready var ray : RayCast3D = $RayCast3D

var fired_by_player

func _ready():
	$Life.start()

func _physics_process(delta):
	position += transform.basis * Vector3(0, -SPEED, 0) * delta

# Despawn the bullet after some time
func _on_life_timeout() -> void:
	queue_free()

func set_collision_layers(is_held_by_player:bool) -> void:
	set_collision_layer_value(CollisionLayers.ENEMY_DAMAGE, is_held_by_player)
	set_collision_layer_value(CollisionLayers.PLAYER_DAMAGE, !is_held_by_player)

func projectile_damage():
	return damage
	
func set_damage(dmg):
	damage = dmg
	
func set_type(t):
	type = t
