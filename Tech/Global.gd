extends Node

var save_path : String = "user://Saves/"
var selected_save : String = ""

enum GameOverStatus {
	Won,
	Died,
	Lost
}

#func pause_game(wait_for_timer = null):
#	pause_mutex.lock()
#	if wait_for_timer != null:
#		wait_for_timer.paused = true
#	get_tree().paused = true
#
#func resume_game(wait_for_timer = null):
#	pause_mutex.unlock()
#	if wait_for_timer != null:
#		wait_for_timer.paused = false
#	get_tree().paused = false
