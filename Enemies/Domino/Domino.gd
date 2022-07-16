extends KinematicBody2D
export(int) var SPEED: int = 150
var velocity: Vector2 = Vector2.ZERO

var path: Array = []	# Contains destination positions
var levelNavigation: Navigation2D = null
var player = null
var player_spotted: bool = false

onready var los = $LineOfSight
onready var debugText = $DebugText
onready var tree = get_tree()
onready var enemyHandler = tree.get_nodes_in_group("EnemyHandler")[0]

var last_spotted_player_pos: Vector2 = Vector2.ZERO
var reached_last_player_pos: bool = true

var diceRoll		# The life this enemy has.
const MAX_ROLL = 6

func _ready():
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

func _physics_process(_delta):
	if player:
		los.look_at(player.global_position)
		check_player_in_detection()
		if player_spotted:
			last_spotted_player_pos = player.global_position
			reached_last_player_pos = false
			generate_path()
			navigate()
		elif !reached_last_player_pos:
			navigate_to_old_position()
	if !reached_last_player_pos:
		move()

# PATHFINDING FUNCTIONS

func check_player_in_detection() -> bool:
	var collider = los.get_collider()
	if collider and collider.is_in_group("Player"):
		player_spotted = true
		return true
	player_spotted = false
	return false

func navigate():	# Define the next position to go to
	if path.size() > 1:
		velocity = global_position.direction_to(path[1]) * SPEED

		# If reached the destination, remove this point from path array
		if global_position.distance_to(path[0]) < 1:
			path.pop_front()

func navigate_to_old_position():
	velocity = global_position.direction_to(last_spotted_player_pos) * SPEED

	if global_position.distance_to(last_spotted_player_pos) < 1:
		reached_last_player_pos = true

func generate_path():	# It's obvious
	if levelNavigation != null and player != null:
		path = levelNavigation.get_simple_path(global_position, player.global_position, false)

func move():
	velocity = move_and_slide(velocity.floor())
