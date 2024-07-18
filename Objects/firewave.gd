extends Node2D

var direction = Vector2.DOWN
var speed = 2
var damage = 50


func _physics_process(_delta):
	position += direction * speed


func _on_area_2d_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)

