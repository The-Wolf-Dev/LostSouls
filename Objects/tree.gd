extends StaticBody2D

@export var tree_type: int = 1

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var min_tree_id: int = 1
@onready var max_tree_id: int = 3


func _ready():
	init_tree()

func validate_tree_type(value: int) -> int:
	if value < min_tree_id:
		value = min_tree_id
	if value > max_tree_id:
		value = max_tree_id
	return value

func init_tree():
	sprite.texture = ResourceLoader.load("res://Assets/The Fan-tasy Tileset/Art/Trees and Bushes/Tree_Emerald_" + str(validate_tree_type(tree_type)) + ".png")
	sprite.position.y = -sprite.texture.get_height() / 3.5
	collision.position.y = -sprite.position.y - 11
