extends KinematicBody2D

enum {
	FOLLOW,
	ATTACK,
	RETRACT
}

var state = FOLLOW

onready var player = get_parent().get_node("Player")
onready var sprite = $Sprite
onready var retractTimer = $RetractTimer

const FOLLOW_SPEED = 4.0
const FOLLOW_OFFSET = -10

var initialPosition
var finalPosition
var curvePosition

var t = 0.0
const ATTACK_DURATION = 0.8
const RETRACT_DURATION = 1.5

const RADIUS = 250

func _physics_process(delta):
	
	match state:
		FOLLOW:
			follow_state(delta)
		ATTACK:
			attack_state(delta, initialPosition, finalPosition, curvePosition)
		RETRACT:
			retract_state(delta)
			
	if Input.is_action_just_pressed("retract") && state == ATTACK:
		retractTimer.start()
		state = RETRACT
		
	if Input.is_action_just_pressed("attack"):
		retractTimer.stop()
		define_bezier_variables()
		state = ATTACK
		


func follow_state(delta):
	follow_player(delta, FOLLOW_SPEED)

func attack_state(delta, initialPosition, finalPosition, curvePosition):
	# Move from initialPosition to finalPosition, taking into account curvePosition
	t += delta / ATTACK_DURATION
	
	var q0 = initialPosition.linear_interpolate(curvePosition, min(t, 1.0))
	var q1 = curvePosition.linear_interpolate(finalPosition, min(t, 1.0))
	position = q0.linear_interpolate(q1, min(t, 1.0))

func retract_state(delta):
	sprite.rotation += 8 * delta
	follow_player(delta, FOLLOW_SPEED * 1.5)
	
	var playerPosition = player.position - Vector2(0, FOLLOW_OFFSET)
	if position.distance_to(playerPosition) < 30:
		state = FOLLOW
	
func _on_RetractTimer_timeout():
	state = FOLLOW
	
func follow_player(delta, followSpeed):
	position = position.linear_interpolate(player.position - Vector2(0, FOLLOW_OFFSET), delta * followSpeed)

func mouse_position_clamped_radius(playerPosition):
	var mousePosition = get_global_mouse_position()
	var distance = playerPosition.distance_to(mousePosition) 
	var mouse_dir = (mousePosition-playerPosition).normalized()
	if distance > RADIUS:
		mousePosition = playerPosition + (mouse_dir * RADIUS)
	return mousePosition

func define_bezier_variables():
	t = 0 # Reset timer
	initialPosition = position
	finalPosition = mouse_position_clamped_radius(position)
	
	var midPoint = Vector2((finalPosition.x - initialPosition.x) / 2 + initialPosition.x, (finalPosition.y - initialPosition.y) / 2 + initialPosition.y)
	curvePosition = Vector2(midPoint.x, midPoint.y - 300)
