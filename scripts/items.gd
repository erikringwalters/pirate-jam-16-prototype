extends Node

var weapons : Dictionary = {
	"Dagger" : "", 
	"Sword" : "", 
	"Handgun" : "", 
	"Shotgun" : "", 
	"Rocket" : ""
}

var projectiles : Dictionary = {
	"Bullet" : "res://scenes/weapons/bullet.tscn"
}

@onready var projectile_scene : PackedScene = ResourceLoader.load(projectiles["Bullet"])

func _ready() -> void:
	for weapon in weapons.keys():
		weapons[weapon] = ResourceLoader.load("res://assets/weapons/" + weapon + ".fbx")
