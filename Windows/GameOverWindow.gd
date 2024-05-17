extends CanvasLayer

@onready var label = $Control/CenterContainer/VBoxContainer/Label
@onready var animation_player = $AnimationPlayer

func set_label_text(status : Global.GameOverStatus):
	if status == Global.GameOverStatus.Won:
		label.text = "You won"
	elif status == Global.GameOverStatus.Lost:
		label.text = "You lost"
	else:
		label.text = "You died"


func show_menu():
	show()
	animation_player.play("show")


func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://Levels/game.tscn")


func _on_finish_game_pressed():
	get_tree().change_scene_to_file("res://Windows/MainMenu.tscn")
