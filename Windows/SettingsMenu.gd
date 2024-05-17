extends CanvasLayer

@onready var fullscreen_check_button = $HBoxContainer/Panel/Fullscreen/CheckButton
@onready var screen_res_list = $HBoxContainer/Panel/ScreenRes/OptionButton
@onready var screen_sizes : Array[Vector2i] = [Vector2i(1280,720), Vector2i(1920, 1080), Vector2i(2560, 1440), Vector2i(3840, 2160)]


func _ready():
	init_screen_res_list()
	screen_res_list.select(1)
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		fullscreen_check_button.set_pressed(true)

func _on_back_pressed():
	hide()

func _input(event):
	if event.is_action_pressed("esc"):
		hide()


func _on_check_button_toggled(button_pressed):
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		screen_res_list.disabled = true
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		screen_res_list.disabled = false

func init_screen_res_list():
	var index : int = 0
	for screen_res in screen_sizes:
		screen_res_list.add_item(str(screen_res.x) + "x" + str(screen_res.y), index)
		index+=1


func _on_option_button_item_selected(index):
	DisplayServer.window_set_size(screen_sizes[index])
