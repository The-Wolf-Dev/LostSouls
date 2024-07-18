extends Button

@export var save_name : String = "Name"
@export var save_date : String = "Date"

signal save_selected(save_name : String)

func _ready():
	$NameContainer/Name.text = save_name
	$DateContainer/Date.text = save_date


func _on_pressed():
	save_selected.emit(save_name)
