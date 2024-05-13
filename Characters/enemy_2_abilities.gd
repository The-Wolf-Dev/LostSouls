extends enemy_1_ability

signal fireball(pos, direction)

@onready var marker = $MarkerRotation/Marker2D
@onready var fireball_cooldown_timer = $Node/FireballCooldownTimer

var is_triggered = false
var target_body = null
var can_shoot_fireball = true

func _physics_process(_delta):
	if is_triggered and target_body != null:
		shoot_fireball(target_body)

func update_marker_rotation(dir):
	$MarkerRotation.rotation = dir.angle()

func get_marker_global_pos(dir):
	update_marker_rotation(dir)
	return marker.global_position

func update_direction(dir):
	direction = dir
	update_animation()

func shoot_fireball(body):
	if can_shoot_fireball:
		var dir = (body.global_position - position).normalized()
		var pos = get_marker_global_pos(dir)
		update_direction(dir)
		fireball.emit(pos, dir)
		fireball_cooldown_timer.start()
		can_shoot_fireball = false

func _on_fireball_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		update_state_machine(states[Idle])
		set_physics_process(false)
		is_triggered = true
		target_body = body


func _on_fireball_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		set_physics_process(true)
		is_triggered = false
		target_body = null


func _on_fireball_cooldown_timer_timeout():
	can_shoot_fireball = true

func save():
	var data_to_save = {
		"is_triggered": is_triggered,
		"target_body": target_body,
		"can_shoot_fireball": can_shoot_fireball
	}
	var parent_data = super.save()
	parent_data.merge(data_to_save)
	return parent_data
