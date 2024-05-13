extends simple_enemy

class_name enemy_1_ability

func _on_stun_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		body.stun()
