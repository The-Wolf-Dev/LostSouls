extends CharacterBody2D

signal fireball(pos, direction)
signal firewave(pos, direction)

@onready var animation_player = $AnimationPlayer as AnimationPlayer
@onready var animation_tree = $AnimationPlayer/AnimationTree as AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var sprites = $Sprites as Node2D
@onready var marker = $MarkerRotation/Marker2D as Marker2D

@export var move_speed = 100
@export var sprint_increase = 50
@export var character_direction = Vector2.DOWN
@export var is_slashing = false:
	set(value):
		is_slashing = value
		print(is_slashing)

enum {
	Idle,
	Walk,
	Slash
}

enum Abilities {
	Fireball,
	Firewave
}

const states = {Idle: "Idle", Walk: "Walk", Slash: "Slash"}
var state : String = states[Idle]
var selected_ability : Abilities = Abilities.Fireball
var can_shoot_fireball : bool = true
var can_shoot_firewave : bool = true


func _input(event):
	if event.is_action_pressed("sprint"):
		move_speed += sprint_increase
	
	if event.is_action_released("sprint"):
		move_speed -= sprint_increase
	
	if event.is_action_pressed("left_mouse_click"):
		slash()
	
	if event.is_action_pressed("fireball"):
		selected_ability = Abilities.Fireball
	
	if event.is_action_pressed("firewave"):
		selected_ability = Abilities.Firewave
	
	if event.is_action_pressed("right_mouse_click"):
		update_marker_rotation()
		var pos = marker.global_position
		var dir = (get_global_mouse_position() - position).normalized()
		if selected_ability == Abilities.Fireball:
			shoot_fireball(pos, dir)
		elif selected_ability == Abilities.Firewave:
			shoot_firewave(pos, dir)

func _ready():
	animation_tree.active = true
	update_animation(character_direction)

func _physics_process(_delta):
	get_input()
	update_state()
	move_and_slide()

func get_input():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	update_animation(input_direction)
	velocity = input_direction * move_speed * int(!is_slashing)

func update_animation(move_input : Vector2):
	if(move_input != Vector2.ZERO and !is_slashing):
		animation_tree.set("parameters/Idle/blend_position", move_input)
		animation_tree.set("parameters/Walk/blend_position", move_input)
		animation_tree.set("parameters/Slash/blend_position", move_input)

func update_state():
	if is_slashing:
		return
	if(velocity != Vector2.ZERO):
		state = states[Walk]
	else:
		state = states[Idle]
	update_state_machine()

func update_state_machine():
	set_active_sprite(state)
	state_machine.travel(state)

func set_active_sprite(state_name : String):
	for node in sprites.get_children():
		if node.name == state_name:
			node.visible = true
		else:
			node.visible = false

func save():
	var data_to_save = {
		"file_path" : get_scene_file_path(),
		"parent_path" : get_parent().get_path(),
		"position_x" : position.x,
		"position_y" : position.y,
	}
	
	return data_to_save


func _on_fireball_timer_timeout():
	can_shoot_fireball = true

func slash():
	is_slashing = true
	state = states[Slash]
	update_state_machine()

func shoot_fireball(pos, dir):
	if can_shoot_fireball:
		#can_fireball = false
		#$Timers/FireballTimer.start()
		fireball.emit(pos, dir)

func shoot_firewave(pos, dir):
	if can_shoot_fireball:
		#can_fireball = false
		#$Timers/FireballTimer.start()
		firewave.emit(pos, dir)

func update_marker_rotation():
	$MarkerRotation.rotation = get_local_mouse_position().angle()
