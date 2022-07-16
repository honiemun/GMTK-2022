extends KinematicBody2D

# STATE MACHINE
enum {
	FOLLOW,
	ATTACK,
	RETRACT
}

var state = FOLLOW

# DICE ROLLS
var rng = RandomNumberGenerator.new()
var rawDiceRoll 	# The original dice roll from one to six.
var diceRoll		# The raw dice roll + any modifiers.
var modifier = 0	# Modifiers that change the dice roll.

const MAX_DICE_ROLL = 6

# TRAVERSAL ANIMATIONS

var initialPosition
var finalPosition
var curvePosition

const FOLLOW_SPEED = 4.0
const FOLLOW_OFFSET = -10

var t = 0.0

# ATTACKS

const ATTACK_DURATION = 0.8
const RETRACT_DURATION = 1.5
const RADIUS = 250

# OTHER NODES
onready var player = get_parent().get_node("Player")
onready var sprite = $Sprite
onready var retractTimer = $RetractTimer
onready var debugText = $DebugText

func _physics_process(delta):
	
	match state:
		FOLLOW:
			follow_state(delta)
		ATTACK:
			attack_state(delta)
		RETRACT:
			retract_state(delta)
			
	if Input.is_action_just_pressed("retract") && state == ATTACK && t > ATTACK_DURATION:
		retractTimer.start()
		state = RETRACT
		
	if Input.is_action_just_pressed("attack") && state != ATTACK:
		retractTimer.stop()
		roll_dice()
		define_bezier_variables()
		state = ATTACK
		


func follow_state(delta):
	follow_player(delta, FOLLOW_SPEED)

func attack_state(delta):
	move_towards_curve(delta)

func roll_dice():
	rawDiceRoll = rng.randi_range(1, MAX_DICE_ROLL)
	diceRoll = rawDiceRoll
	debugText.set_text(str(diceRoll))
	print("Rolled a " + str(diceRoll))

func add_to_dice(mod):
	if diceRoll and rawDiceRoll:
		modifier += mod
		diceRoll += modifier
		debugText.set_text(str(diceRoll))

func move_towards_curve(delta):
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
