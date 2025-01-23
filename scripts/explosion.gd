extends Area3D

var damage : float 
var items_in_radius : Array
var explosion_force : int = 10

func _ready() -> void:
	$Lifetime.start()

func _physics_process(delta: float) -> void:
	const rate = 1.1
	get_node('MeshInstance3D').mesh.radius *= rate
	get_node('MeshInstance3D').mesh.height = get_node('MeshInstance3D').mesh.radius*2
	
func _on_lifetime_timeout() -> void:
	explosion()
	get_node('MeshInstance3D').mesh.radius = 1.0
	get_node('MeshInstance3D').mesh.height = get_node('MeshInstance3D').mesh.radius*2
	queue_free()
		
# Adding the rigidbodies to an array that entered into the explosion area.
func _on_body_entered(body: Node3D) -> void:
	if body.name != self.name:
		print('oooh a body')
		if body is RigidBody3D:
			print('append')
			items_in_radius.append(body)

# Deleting the rigidbodies from the array that exited the explosion area.
func _on_body_exited(body: Node3D) -> void:
	if body is RigidBody3D:
		items_in_radius.erase(body)

func explosion():
	var force_dir : Vector3
	var random_vector : Vector3
	#Applying the explosion force for every Rigidbody in the array.
	for j in items_in_radius:
		#Getting a direction vector between the bomb and all nearby RigidBodies. This line of code later helps to calculate a trajectory    for the Rigidbodies.
		force_dir = global_position.direction_to(j.global_position)
		#Make it go up because otherwise it is shoved into the ground
		#force_dir += Vector3(0.0,2.0,0.0)
		#Generating a position on the object where the force will be applied. This line of code makes the Rigidbodies randomly rotate after the explosion.
		random_vector = Vector3(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1)) * force_dir
		#j.apply_impulse(random_vector, force_dir * explosion_force)
		# can also probably be this if we don't want spin:
		j.apply_impulse(force_dir * explosion_force, force_dir)
		
func explosion_damage() -> float:
	return damage
	
func set_damage(dmg) -> void:
	damage = dmg
