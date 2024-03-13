extends CharacterBody2D


@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")


@export var move_speed = 100
@export var start_position = Vector2(0, 1)


func _ready():
	update_animation(start_position)

func _physics_process(_delta):
	get_input()
	update_state_machine()
	move_and_slide()

func get_input():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	update_animation(input_direction)
	velocity = input_direction * move_speed

func update_animation(move_input : Vector2):
	if(move_input != Vector2.ZERO):
		animation_tree.set("parameters/Idle/blend_position", move_input)
		animation_tree.set("parameters/Walk/blend_position", move_input)

func update_state_machine():
	if(velocity != Vector2.ZERO):
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")

func save():
	var data_to_save = {
		"file_path" : get_scene_file_path(),
		"parent_path" : get_parent().get_path(),
		"position_x" : position.x,
		"position_y" : position.y,
	}
	
	return data_to_save

