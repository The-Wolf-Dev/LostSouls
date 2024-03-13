extends CanvasLayer

@onready var settings_menu = $Pages/Settings
@onready var savings_menu = $Pages/Savings

func _ready():
	savings_menu.save_disabled = true


func _on_quit_game_pressed():
	get_tree().quit()


func _on_new_game_pressed():
	Global.selected_save = ""
	get_tree().change_scene_to_file("res://Levels/game.tscn")


func _on_settings_pressed():
	settings_menu.show()


func _on_load_pressed():
	savings_menu.show()


func _on_savings_load_requested(save_name):
	Global.selected_save = save_name
	get_tree().change_scene_to_file("res://Levels/game.tscn")

