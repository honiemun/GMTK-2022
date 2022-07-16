extends Node2D

var horde = 1
var difficulty = 2 # Decreases slightly for every horde, making rolls higher.

var rng = RandomNumberGenerator.new()
var last_spotted_player_pos: Vector2 = Vector2.ZERO
var reached_last_player_pos: bool = true

func roll_enemy_stats(maxRoll, difficultyOn):
	maxRoll = (round(maxRoll / difficulty) if difficultyOn else maxRoll)
	return rng.randi_range(1, maxRoll)

# PATHFINDING AND NAVIGATION

func follow_player(enemy, player):
	if player:
		enemy.los.look_at(player.global_position)
		var player_spotted = check_player_in_detection(enemy)
		if player_spotted:
			last_spotted_player_pos = player.global_position
			reached_last_player_pos = false
			var path = generate_path(enemy, player)
			navigate(enemy)
		elif !reached_last_player_pos:
			navigate_to_old_position(enemy)
		if !reached_last_player_pos:
			move(enemy, enemy.velocity)

func check_player_in_detection(enemy) -> bool:
	var collider = enemy.los.get_collider()
	if collider and collider.is_in_group("Player"):
		return true
	return false

func generate_path(enemy, player):	# It's obvious
	if enemy.levelNavigation != null and player != null:
		return enemy.levelNavigation.get_simple_path(enemy.global_position, player.global_position, false) as Array

func navigate(enemy):	# Define the next position to go to
	if enemy.path.size() > 1:
		enemy.velocity = enemy.global_position.direction_to(enemy.path[1]) * enemy.SPEED

		# If reached the destination, remove this point from path array
		if enemy.global_position.distance_to(enemy.path[0]) < 1:
			enemy.path.pop_front()

func navigate_to_old_position(enemy):
	enemy.velocity = enemy.global_position.direction_to(last_spotted_player_pos) * enemy.SPEED

	if enemy.global_position.distance_to(last_spotted_player_pos) < 1:
		reached_last_player_pos = true

func move(enemy, velocity):
	enemy.velocity = enemy.move_and_slide(velocity.floor())
