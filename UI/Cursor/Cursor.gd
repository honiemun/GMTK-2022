extends Node2D

onready var cursorSprite = $CursorSprite

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta):
	# Rotate the sprite & set to position of mouse
	cursorSprite.rotation += 1 * delta
	position = get_global_mouse_position()
