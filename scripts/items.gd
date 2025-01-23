extends Node

var weapons : Dictionary = {
	"Dagger" : "", 
	"Sword" : "", 
	"Handgun" : "", 
	"Shotgun" : "", 
	"Rocket" : ""
}

@onready var projectiles : Dictionary = {
	"Bullet" : ResourceLoader.load("res://scenes/weapons/bullet.tscn"),
	"Rocket" : ResourceLoader.load("res://scenes/weapons/rocket_projectile.tscn"),
}

func _ready() -> void:
	for weapon in weapons.keys():
		weapons[weapon] = ResourceLoader.load("res://scenes/weapons/" + weapon.to_lower() + ".tscn")
