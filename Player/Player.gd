extends KinematicBody2D

enum {
	MOVE,
	HURT,
	DEAD
}

var health = 6

var state          = MOVE
var canBeHurt      = true
var velocity       = Vector2.ZERO

const max_speed    = 360
const acceleration = 1000
const friction     = 1000

onready var dice = get_tree().get_nodes_in_group("Dice")[0]
onready var camera = $Camera2D
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

var knockback = Vector2.ZERO
const knockback_power = 400
var isKnocked = false
var last_pos = global_position

signal player_hit

func _ready():
	set_process(true)
	animationTree.active = true
	
func _physics_process(delta):
	update()
	
	match state:
		MOVE:
			move_state(delta)
		HURT:
			hurt_state(delta)

# States

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector = Vector2(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
			Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")).clamped(1)
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
		animationState.travel("walk")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		animationState.travel("idle")
	move()

func hurt_state(delta):
	knockback = knockback.move_toward(Vector2.ZERO, friction * delta)
	knockback = move_and_slide(knockback)
	if global_position == last_pos:
		isKnocked = false
	last_pos = global_position

func move():
	velocity = move_and_slide(velocity)

# Line drawing

#func _draw():
#	draw_line(Vector2(0,0), dice.mouse_position_clamped_radius(Vector2(0,0)), Color(255, 0, 0), 1)

func _on_Hitbox_area_entered(area):
	var enemy = area.get_parent()
	if state != DEAD && canBeHurt && area.is_in_group("EnemyHitbox"):
		canBeHurt = false
		if "diceRoll" in enemy:
			#health -= enemy.diceRoll
			health -= 1
			emit_signal("player_hit", health)
			if health > 0:
				state = HURT
				$InvincibilityFrames.start()
				knockback = enemy.global_position.direction_to(global_position) * knockback_power
				animationState.travel("hurt")
			else:
				state = DEAD
				animationState.travel("dead")


func _on_InvincibilityFrames_timeout():
	canBeHurt = true

func _on_Hurt_Endframe():
	state = MOVE
