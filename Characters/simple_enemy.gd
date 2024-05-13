extends CharacterBody2D

class_name simple_enemy

signal died

enum {
	Idle,
	Walk
}

@export var health : int = 50:
	set(value):
		health = max(0, value)
@export var speed : int = 50
@export var direction : Vector2 = Vector2.DOWN

@onready var nav_agent = $NavigationAgent2D as NavigationAgent2D
@onready var animation_tree = $AnimationPlayer/AnimationTree as AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

var target_pos : Vector2 = Vector2.ZERO
var current_state : String = states[Idle]

const states = {Idle: "Idle", Walk: "Walk"}

func _ready():
	set_nav_agent_target_pos(target_pos)
	animation_tree.active = true
	update_animation()

func _physics_process(_delta):
	follow_path()
	move()

func move():
	velocity = direction * speed
	update_animation()
	update_state()
	move_and_slide()

func _exit_tree():
	died.emit()

func update_animation():
	if(direction != Vector2.ZERO):
		animation_tree.set("parameters/Idle/blend_position", direction)
		animation_tree.set("parameters/Walk/blend_position", direction)

func update_state():
	if(velocity != Vector2.ZERO):
		update_state_machine(states[Walk])
	else:
		update_state_machine(states[Idle])

func update_state_machine(state):
	if not current_state == state:
		state_machine.travel(state)
		current_state = state

func set_nav_agent_target_pos(pos : Vector2):
	nav_agent.target_position = pos

func take_damage(value):
	health-=value
	if health == 0:
		queue_free()

func follow_path():
	if not nav_agent.is_target_reached():
		var next_path_point = nav_agent.get_next_path_position()
		direction = (next_path_point - global_position).normalized()

func save():
	var data_to_save = {
		"file_path" : get_scene_file_path(),
		"parent_path" : get_parent().get_path(),
		"position_x" : position.x,
		"position_y" : position.y,
		"health": health,
		"target_pos_x": target_pos.x,
		"target_pos_y": target_pos.y,
	}
	
	data_to_save.merge(save_signal_list())
	return data_to_save

func save_signal_list():
	var data_to_save : Dictionary = {}
	
	for sig in get_signal_list():
		var sig_name = sig["name"]
		var sig_con_list = get_signal_connection_list(sig_name)
		if not sig_con_list.is_empty():
			data_to_save[sig_name] = str(sig_con_list[0]["callable"]).get_slice(":",2)
	
	return data_to_save
