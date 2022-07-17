extends KinematicBody2D
export(int) var SPEED: int = 150
var velocity: Vector2 = Vector2.ZERO

var path: Array = []	# Contains destination positions
var levelNavigation: Navigation2D = null
var player = null
var dice = null
var player_spotted: bool = false

onready var los = $LineOfSight
onready var debugText = $DebugText
onready var face = $Sprite/DiceNumber
onready var tree = get_tree()
onready var enemyHandler = tree.get_nodes_in_group("EnemyHandler")[0]
onready var hordeHandler = tree.get_nodes_in_group("HordeHandler")[0]

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

var last_spotted_player_pos: Vector2 = Vector2.ZERO
var reached_last_player_pos: bool = true

var last_pos = global_position

var diceRoll		# The life this enemy has.
const MAX_ROLL = 6

var knockback = Vector2.ZERO
const friction = 200
const knockback_power = 250
var isKnocked = false
var canMove = true

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
	if canMove:
		animationState.travel("Walk")
		if !isKnocked:
			enemyHandler.follow_player(self, player)
		else:
			knockback = knockback.move_toward(Vector2.ZERO, friction * delta)
			knockback = move_and_slide(knockback)
			if global_position == last_pos:
				isKnocked = false
			last_pos = global_position
		determine_facing()
	set_dice_animation()

func _on_Hurtbox_area_entered(area):
	if dice:
		if dice.canAttack:
			diceRoll -= dice.rawDiceRoll
			Global.camera.shake(0.3,6)
			debugText.set_text(str(diceRoll))
			
			$Hit.play()
			
			if diceRoll <= 0:
				queue_free()
				hordeHandler.enemy_defeated()
			else:
				isKnocked = true
				knockback = dice.global_position.direction_to(global_position) * knockback_power

# ATTACK ANIMATIONS

func determine_facing():
	var input_vector
	
	if player:
		if player.global_position.x > global_position.x:
			input_vector = 1
		else:
			input_vector = -1
		
		animationTree.set("parameters/Walk/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)

func set_dice_animation():
	face.animation = "Dice"
	if diceRoll:
		face.frame = diceRoll - 1

func _on_Proximity_area_entered(area):
	canMove = false
	animationState.travel("Attack")

func attack_finished():
	canMove = true
