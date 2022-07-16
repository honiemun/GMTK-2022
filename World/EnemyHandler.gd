extends Node2D

var horde = 1
var difficulty = 2 # Decreases slightly for every horde, making rolls higher.

var rng = RandomNumberGenerator.new()

func roll_enemy_stats(maxRoll, difficultyOn):
	maxRoll = (round(maxRoll / difficulty) if difficultyOn else maxRoll)
	return rng.randi_range(1, maxRoll)
