extends KinematicBody2D
export(int) var SPEED: int = 200
var og_speed = SPEED
var velocity: Vector2 = Vector2.ZERO

var path: Array = []	# Contains destination positions
var levelNavigation: Navigation2D = null
var player = null
var dice = null
var player_spotted: bool = false

onready var los = $LineOfSight
onready var debugText = $DebugText
onready var tree = get_tree()
onready var enemyHandler = tree.get_nodes_in_group("EnemyHandler")[0]
onready var hordeHandler = tree.get_nodes_in_group("HordeHandler")[0]

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var sprite = $Sprite

var last_spotted_player_pos: Vector2 = Vector2.ZERO
var reached_last_player_pos: bool = true

var last_pos = global_position

var diceRoll		# The life this enemy has.
const MAX_ROLL = 4

var knockback = Vector2.ZERO
const friction = 200
const knockback_power = 250
var isKnocked = false
var canMove = true
var isOnBoost = false

signal enemy_defeated

func _ready():
	animationTree.active = true
	
	# Roll for STATS
	diceRoll = enemyHandler.roll_enemy_stats(MAX_ROLL, true)
	debugText.set_text(str(diceRoll))
	
	# Get PLAYER and LEVELNAVIGATION
	yield(get_tree(), "idle_frame") # ???
	if tree.has_group("LevelNavigation"):
		levelNavigation = tree.get_nodes_in_group("LevelNavigation")[0]
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]
		last_spotted_player_pos = player.global_position
	if tree.has_group("Dice"):	
		dice = tree.get_nodes_in_group("Dice")[0]

func _physics_process(delta):

	if !isOnBoost:
		get_input_vector()
		animationState.travel("Idle")
	if !isKnocked:
		enemyHandler.follow_player(self, player)
	else:
		knockback = knockback.move_toward(Vector2.ZERO, friction * delta)
		knockback = move_and_slide(knockback)
		if global_position == last_pos:
			isKnocked = false
		last_pos = global_position

func get_input_vector():
	var input_vector
	var rotation = fmod(los.rotation_degrees, 360)
	print(-rotation)
	# SPAGHETTI
	if rotation >= 337.5 && rotation < 22.5 || rotation < 0:
		input_vector = Vector2(1, 0) # RIGHT
	elif rotation >= 22.5 && rotation < 67.5:
		input_vector = Vector2(1, -1) # RIGHT UP
	elif rotation >= 67.5 && rotation < 112.5:
		input_vector = Vector2(0, -1) # UP
	elif rotation >= 112.5 && rotation < 157.5:
		input_vector = Vector2(-1, -1) # LEFT UP
	elif rotation >= 157.5 && rotation < 202.5:
		input_vector = Vector2(-1, 0) # LEFT
	elif rotation >= 202.5 && rotation < 247.5:
		input_vector = Vector2(-1, 1) # LEFT DOWN
	elif rotation >= 247.5 && rotation < 292.5:
		input_vector = Vector2(0, 1) # DOWN
	elif rotation >= 292.5 && rotation < 337.5:
		input_vector = Vector2(1, 1) # RIGHT DOWN
	
	animationTree.set("parameters/Idle/blend_position", input_vector)

func _on_Hurtbox_area_entered(area):
	if dice.canAttack:
		diceRoll -= dice.rawDiceRoll
		debugText.set_text(str(diceRoll))
		Global.camera.shake(0.3,6)
		
		if diceRoll <= 0:
			queue_free()
			hordeHandler.enemy_defeated()
		else:
			isKnocked = true
			knockback = dice.global_position.direction_to(global_position) * knockback_power

# ATTACK ANIMATIONS

func _on_Proximity_area_entered(area):
	isOnBoost = true
	SPEED = 400
	animationState.travel("Attack")

func attack_finished():
	isOnBoost = false
	SPEED = 200
