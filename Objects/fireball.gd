extends Node2D

var direction = Vector2.DOWN
var speed = 1


func _physics_process(_delta):
	position += direction * speed


func _on_area_2d_body_entered(body):
	if body.name == "Enemy":
		body.queue_free()
	
	queue_free()
