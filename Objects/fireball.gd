extends Node2D

var direction = Vector2.DOWN
var speed = 2
var damage = 50

@onready var anim_player = $AnimationPlayer
@onready var fly_timer = $Timers/FlyTimer

func _ready():
	fly_timer.start()

func _physics_process(_delta):
	position += direction * speed


func _on_area_2d_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	play_hit_anim()

func play_destroy_anim():
	anim_player.play("destroy")


func play_hit_anim():
	speed = 0
	fly_timer.stop()
	anim_player.play("hit")


func _on_fly_timer_timeout():
	play_destroy_anim()
