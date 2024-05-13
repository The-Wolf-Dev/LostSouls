extends CharacterBody2D

signal died()
signal health_changed(value : int)

signal fireball(pos, direction)
signal firewave(pos, direction)

signal can_shoot_fireball_changed(value : bool)
signal can_shoot_firewave_changed(value : bool)
signal can_apply_fireshield_changed(value : bool)
signal can_heal_changed(value : bool)

signal fireball_selected()
signal firewave_selected()
signal fireshield_selected()
signal heal_selected()

enum {
	Idle,
	Walk,
	Slash
}

enum Abilities {
	Fireball,
	Firewave,
	Fireshield,
	Heal
}

@onready var animation_player = $AnimationPlayer as AnimationPlayer
@onready var animation_tree = $AnimationPlayer/AnimationTree as AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var sprites = $Sprites as Node2D
@onready var marker = $MarkerRotation/Marker2D as Marker2D
@onready var slash_area = $SlashArea2D as Area2D
@onready var fireball_cooldown_timer = $Timers/FireballCooldownTimer as Timer
@onready var firewave_cooldown_timer = $Timers/FirewaveCooldownTimer as Timer
@onready var fireshield_timer = $Timers/FireshieldTimer as Timer
@onready var fireshield_cooldown_timer = $Timers/FireshieldCooldownTimer as Timer
@onready var heal_cooldown_timer = $Timers/HealCooldownTimer as Timer
@onready var stun_timer = $Timers/StunTimer as Timer
@onready var fireshield_sprite = $Effects/Fireshield
@onready var heal_sprite = $Effects/Heal
@onready var stun_sprite = $Effects/Stun

const max_health = 200
@export var health = max_health:
	set(value):
		health = clamp(value, 0, max_health)
		health_changed.emit(health)
@export var speed = 100
var move_speed = speed
@export var sprint_increase = 50
@export var slash_damage = 50
@export var heal_value = 50
@export var character_direction = Vector2.DOWN
@export var slash_direction = Vector2.DOWN
@export var is_shielded = false
@export var is_stanned = false
@export var is_slashing = false:
	set(value):
		is_slashing = value
		#print("Slashing is " + str(is_slashing))

const states = {Idle: "Idle", Walk: "Walk", Slash: "Slash"}
var selected_ability : Abilities = Abilities.Fireball
var current_state : String = states[Idle]
var can_shoot_fireball : bool = false:
	set(value):
		can_shoot_fireball = value
		can_shoot_fireball_changed.emit(value)
		#print("can_shoot_fireball is " + str(can_shoot_fireball))
var can_shoot_firewave : bool = false:
	set(value):
		can_shoot_firewave = value
		can_shoot_firewave_changed.emit(value)
var can_apply_fireshield : bool = false:
	set(value):
		can_apply_fireshield = value
		can_apply_fireshield_changed.emit(value)
		#print("can_apply_fireshield is " + str(can_apply_fireshield))
var can_heal : bool = false:
	set(value):
		can_heal = value
		can_heal_changed.emit(value)


func _input(event):
	if event.is_action_pressed("sprint"):
		move_speed += sprint_increase
	
	if event.is_action_released("sprint"):
		move_speed = speed
	
	if event.is_action_pressed("left_mouse_click"):
		if not is_slashing:
			slash()
	
	if event.is_action_pressed("fireball"):
		selected_ability = Abilities.Fireball
		fireball_selected.emit()
	
	if event.is_action_pressed("firewave"):
		selected_ability = Abilities.Firewave
		firewave_selected.emit()
	
	if event.is_action_pressed("fireshield"):
		selected_ability = Abilities.Fireshield
		fireshield_selected.emit()
	
	if event.is_action_pressed("heal"):
		selected_ability = Abilities.Heal
		heal_selected.emit()
	
	if event.is_action_pressed("right_mouse_click"):
		update_marker_rotation()
		var pos = marker.global_position
		var dir = (get_global_mouse_position() - position).normalized()
		if selected_ability == Abilities.Fireball:
			shoot_fireball(pos, dir)
		elif selected_ability == Abilities.Firewave:
			shoot_firewave(pos, dir)
		elif selected_ability == Abilities.Fireshield:
			apply_fireshield()
		elif selected_ability == Abilities.Heal:
			heal()


func _ready():
	animation_tree.active = true
	update_slash_area_rotation()
	update_animation()


func _physics_process(_delta):
	reset_speed()
	get_input()
	update_state()
	move_and_slide()

func reset_speed():
	# using sprint before game was paused can lead to permanent changing of move_speed
	if not Input.is_action_pressed("sprint"):
		move_speed = speed

func take_damage(value):
	if not is_shielded:
		health-=value
		if health == 0:
			died.emit()

func get_input():
	character_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = character_direction * move_speed * int(!is_slashing)
	if character_direction != Vector2.ZERO and character_direction != slash_direction:
		slash_direction = character_direction
	update_animation()


func update_animation():
	if(character_direction != Vector2.ZERO and !is_slashing):
		animation_tree.set("parameters/Idle/blend_position", character_direction)
		animation_tree.set("parameters/Walk/blend_position", character_direction)
		animation_tree.set("parameters/Slash/blend_position", character_direction)


func update_state():
	if is_slashing:
		return
	if(velocity != Vector2.ZERO):
		update_state_machine(states[Walk])
	else:
		update_state_machine(states[Idle])


func update_state_machine(state):
	if not current_state == state:
		set_active_sprite(state)
		state_machine.travel(state)
		current_state = state


func set_active_sprite(state_name : String):
	for node in sprites.get_children():
		if node.name == state_name:
			node.visible = true
		else:
			node.visible = false


func save():
	var data_to_save = {
		"file_path": get_scene_file_path(),
		"parent_path": get_parent().get_path(),
		"position_x": position.x,
		"position_y": position.y,
		"health": health,
		"can_shoot_fireball": can_shoot_fireball,
		"can_shoot_firewave": can_shoot_firewave,
		"can_apply_fireshield": can_apply_fireshield,
		"can_heal": can_heal
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

func slash():
	is_slashing = true
	slash_area.monitoring = true
	update_slash_area_rotation()
	update_state_machine(states[Slash])


func shoot_fireball(pos, dir):
	if can_shoot_fireball:
		can_shoot_fireball = false
		fireball_cooldown_timer.start()
		fireball.emit(pos, dir)


func shoot_firewave(pos, dir):
	if can_shoot_firewave:
		can_shoot_firewave = false
		firewave_cooldown_timer.start()
		firewave.emit(pos, dir)

func play_fireshield_animation():
	fireshield_sprite.visible = true
	animation_player.play("fireshield")

func stop_fireshield_animation():
	fireshield_sprite.visible = false
	animation_player.stop()

func apply_fireshield():
	if can_apply_fireshield:
		can_apply_fireshield = false
		is_shielded = true
		fireshield_timer.start()
		play_fireshield_animation()
		#print("apply_fireshield")

func play_heal_animation():
	heal_sprite.visible = true
	animation_player.play("heal")

func stop_heal_animation():
	heal_sprite.visible = false
	animation_player.stop()

func heal():
	if can_heal:
		health += heal_value
		can_heal = false
		heal_cooldown_timer.start()
		play_heal_animation()
		#print("heal")


func update_slash_area_rotation():
	slash_area.rotation = slash_direction.angle()


func update_marker_rotation():
	$MarkerRotation.rotation = get_local_mouse_position().angle()


func _on_slash_area_2d_body_entered(body):
	if body.has_method("take_damage") and body != self:
		body.take_damage(slash_damage)


func _on_animation_tree_animation_finished(anim_name):
	#print(anim_name + " finished")
	if "slash" in anim_name:
		is_slashing = false
		slash_area.monitoring = false


func _on_fireball_cooldown_timer_timeout():
	can_shoot_fireball = true


func _on_firewave_cooldown_timer_timeout():
	can_shoot_firewave = true


func _on_fireshield_timer_timeout():
	fireshield_cooldown_timer.start()
	is_shielded = false
	stop_fireshield_animation()


func _on_fireshield_cooldown_timer_timeout():
	can_apply_fireshield = true


func _on_heal_cooldown_timer_timeout():
	can_heal = true
	stop_heal_animation()


func select_fireball():
	selected_ability = Abilities.Fireball

func select_firewave():
	selected_ability = Abilities.Firewave

func select_fireshield():
	selected_ability = Abilities.Fireshield

func select_heal():
	selected_ability = Abilities.Heal

func play_stun_animation():
	stun_sprite.visible = true
	animation_player.play("stun")

func stop_stun_animation():
	stun_sprite.visible = false
	animation_player.stop()

func stun():
	if not is_shielded and is_physics_processing():
		set_physics_process(false)
		set_process_input(false)
		update_state_machine(states[Idle])
		play_stun_animation()
		stun_timer.start()


func _on_stun_timer_timeout():
	set_physics_process(true)
	set_process_input(true)
	stop_stun_animation()

func unlock_fireball():
	can_shoot_fireball = true

func unlock_firewave():
	can_shoot_firewave = true

func unlock_fireshield():
	can_apply_fireshield = true

func unlock_heal():
	can_heal = true
