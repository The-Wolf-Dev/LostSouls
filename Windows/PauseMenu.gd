extends CanvasLayer

@onready var settings_menu = $Pages/Settings
@onready var savings_menu = $Pages/Savings

signal resume_pressed()
signal save_requested(save_name : String)


func _input(event):
	if event.is_action_pressed("esc"):
		if get_tree().paused and visible:
			resume_game()
			get_viewport().set_input_as_handled()


func _on_resume_pressed():
	resume_game()


func _on_quit_game_pressed():
	get_tree().quit()


func _on_finish_game_pressed():
	get_tree().change_scene_to_file("res://Windows/MainMenu.tscn")


func _on_settings_pressed():
	settings_menu.show()

func resume_game():
	hide()
	resume_pressed.emit()


func _on_load_pressed():
	savings_menu.update_saves_list()
	savings_menu.show()


func _on_savings_save_requested(save_name : String):
	save_requested.emit(save_name)

