extends KinematicBody2D

enum {
	MOVE,
	ATTACK
}

var state          = MOVE
var velocity       = Vector2.ZERO

const max_speed    = 360
const acceleration = 1000
const friction     = 1000

onready var dice = get_parent().get_node("Dice")

func _physics_process(delta):
	
	match state:
		MOVE:
			move_state(delta)
		ATTACK:
			attack_state()

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector = Vector2(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
			Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")).clamped(1)
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	move()

# States

func attack_state():
	velocity = Vector2.ZERO

func move():
	velocity = move_and_slide(velocity)

# Animations

func attack_animation_finished():
	state = MOVE
