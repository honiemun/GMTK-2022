extends Node2D

onready var scene = get_tree().get_root()
onready var enemiesScene = scene.get_node("World/YSort/Enemies")
onready var spawnAreaPolygon = scene.get_node("World/SpawnArea")

# Enemies
var domino   = "res://Enemies/Domino/Domino.tscn"
var checkers = "res://Enemies/Checkers/Checkers.tscn"
var polycar  = "res://Enemies/Poly Car/PolyCar.tscn"
var rng = RandomNumberGenerator.new()
	
var hordes = [
	[
		domino, checkers,domino, domino, domino, checkers,domino, domino, domino, checkers
	],
	[
		domino, domino, domino, checkers
	]
]

func _ready():
	for enemy in hordes[0]:
		create_enemy(enemy)

func create_enemy(enemy):
	var enemyScene = load(enemy).instance()
	enemiesScene.add_child(enemyScene)
	enemyScene.set_global_position(generate_enemy_coords())

func generate_enemy_coords():
	# Monky brain way of doing this, but fuck you, I'm not doing trigonometry
	var generatedPosition = Vector2(0, 0)
	
	while !Geometry.is_point_in_polygon(generatedPosition, spawnAreaPolygon.get_polygon()):
		rng.randomize()
		var x = rng.randi_range(0, 1328)
		var y = rng.randi_range(-608, 480)
		generatedPosition = Vector2(x, y)
	
	return generatedPosition
