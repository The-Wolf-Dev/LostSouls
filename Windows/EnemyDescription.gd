extends CanvasLayer

signal ok_pressed

@onready var label = $CenterContainer/Panel/TextContainer/Label

@export var enemy_description : String

func _ready():
	label.text = enemy_description


func _on_button_pressed():
	hide()
	ok_pressed.emit()
