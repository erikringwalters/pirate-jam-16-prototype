extends Node

var weapons := ["Dagger", "Sword", "Handgun", "Shotgun", "Rocket"]
var weapon_scenes := []

var projectiles := ["Bullet"]

@onready var projectile_scene : PackedScene = preload("res://scenes/weapons/bullet.tscn")

func _ready() -> void:
	for weapon in weapons:
		weapon_scenes.push_back(ResourceLoader.load("res://assets/weapons/" + weapon + ".fbx"))
		
