extends CanvasLayer


@onready var villagers_alive_label = $VBoxContainer/VillagersAlive
@onready var hero_health_label = $VBoxContainer/HeroHealth
var villagers_alive_text : String = "Villagers alive: "
var hero_health_text : String = "Health: "

@onready var animation_player = $AnimationPlayer
var controls_hidden : bool = true

@onready var fireball = $CenterContainer/ButtonGroup/Fireball
@onready var firewave = $CenterContainer/ButtonGroup/Firewave
@onready var fireshield = $CenterContainer/ButtonGroup/Fireshield
@onready var heal = $CenterContainer/ButtonGroup/Heal

func _input(event):
	if event.is_action_pressed("hide_controls"):
		hide_controls()

func set_fireball_disabled(value):
	# if player's can_shoot_fireball = true, then disabled must be false
	fireball.disabled = !value

func set_firewave_disabled(value):
	# if player's can_shoot_firewave = true, then disabled must be false
	firewave.disabled = !value

func set_fireshield_disabled(value):
	# if player's can_shoot_firewave = true, then disabled must be false
	fireshield.disabled = !value

func set_heal_disabled(value):
	# if player's can_shoot_firewave = true, then disabled must be false
	heal.disabled = !value

func set_fireball_pressed():
	fireball.button_pressed = true

func set_firewave_pressed():
	firewave.button_pressed = true

func set_fireshield_pressed():
	fireshield.button_pressed = true

func set_heal_pressed():
	heal.button_pressed = true

func update_health(value : int):
	hero_health_label.text = hero_health_text + str(value)

func update_villagers_count(value : int):
	villagers_alive_label.text = villagers_alive_text + str(value)


func hide_controls():
	if controls_hidden:
		animation_player.play("show")
	else:
		animation_player.play("hide")
	controls_hidden = !controls_hidden
