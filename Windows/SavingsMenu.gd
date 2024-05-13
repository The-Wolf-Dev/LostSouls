extends CanvasLayer

signal save_requested(save_name : String)

@onready var saves_list = $HBoxContainer/Panel/Saves/ScrollContainer/VBoxContainer
@onready var line_edit = $LineEdit
@onready var save_button = $HBoxContainer/VBoxContainer/Save

@export var save_disabled = false:
	set(value):
		save_disabled = value
		if save_disabled:
			save_button.queue_free()


func _ready():
	init_saves_list()


func _on_back_pressed():
	hide()


func _on_save_pressed():
	if line_edit.text != "":
		save_requested.emit(line_edit.text)
		update_saves_list()


func init_saves_list():
	var saves = DirAccess.open(Global.save_path)
	if saves:
		saves.list_dir_begin()
		var filename = saves.get_next()
		while filename != "":
			if !saves.current_is_dir():
				add_save_to_list(filename)
			filename = saves.get_next()
	else:
		print("SavingsMenu: " + Global.save_path + " doesn't exist")


func _on_load_pressed():
	if Global.selected_save != "":
		get_tree().change_scene_to_file("res://Levels/game.tscn")


func update_saves_list():
	clear_saves_list()
	init_saves_list()


func clear_saves_list():
	var children = saves_list.get_children()
	for child in children:
		saves_list.remove_child(child)


func add_save_to_list(filename):
	var file_creation_date = FileAccess.get_modified_time(Global.save_path + filename)
	var save = load("res://Tech/Save.tscn").instantiate()
	save.save_name = filename
	save.save_date = Time.get_datetime_string_from_unix_time(file_creation_date).replace("T", " ")
	save.save_selected.connect(_on_save_selected)
	saves_list.add_child(save)


func _on_save_selected(save_name : String):
	Global.selected_save = save_name
	line_edit.text = save_name


func _on_delete_pressed():
	if Global.selected_save != "":
		DirAccess.remove_absolute(Global.save_path + Global.selected_save)
		update_saves_list()
		Global.selected_save = ""
		line_edit.text = ""
