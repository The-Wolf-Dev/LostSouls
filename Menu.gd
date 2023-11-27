extends Control


func _on_exit_pressed():
	get_tree().quit(0); # Replace with function body.


func _on_play_pressed():
	get_tree().change_scene_to_file("res://game.tscn") # Replace with function body.
