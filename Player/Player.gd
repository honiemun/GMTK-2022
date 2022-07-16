extends KinematicBody2D

enum {
	MOVE,
	ATTACK
}

var health = 6

var state          = MOVE
var velocity       = Vector2.ZERO

const max_speed    = 360
const acceleration = 1000
const friction     = 1000

onready var dice = get_tree().get_nodes_in_group("Dice")[0]

signal player_hit

func _ready():
	set_process(true)
	
func _physics_process(delta):
	update()
	
	match state:
		MOVE:
			move_state(delta)

# States

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

func move():
	velocity = move_and_slide(velocity)

# Animations

func attack_animation_finished():
	state = MOVE

# Line drawing

#func _draw():
#	draw_line(Vector2(0,0), dice.mouse_position_clamped_radius(Vector2(0,0)), Color(255, 0, 0), 1)


func _on_Hitbox_area_entered(area):
	var enemy = area.get_parent()
	if "diceRoll" in enemy:
		health -= enemy.diceRoll
		emit_signal("player_hit", health)
		#if health <= 0:
			#queue_free()
