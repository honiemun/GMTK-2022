extends KinematicBody2D

var addedToRoll = 1
var rng = RandomNumberGenerator.new()

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var face = $Multiplier
onready var sprite = $AnimatedSprite

onready var dice = get_tree().get_nodes_in_group("Dice")[0]
var canAdd = true

func _ready():
	addedToRoll = rng.randi_range(1,3)
	animationTree.active = true
	set_ring_colour()
	set_multiplier()

func set_ring_colour():
	match addedToRoll:
		1:
			sprite.modulate = Color(0,1,0) # Green ring
		2:
			sprite.modulate = Color(1,1,0)
		3:
			sprite.modulate = Color(1,0,0)

func set_multiplier():
	face.frame = addedToRoll - 1

func _on_Hurtbox_area_entered(_area):
	print("Adding " + str(addedToRoll) + " to dice roll")
	if dice.state != dice.FOLLOW:
		dice.add_to_dice(addedToRoll)
		animationState.travel("Hit")

func destroy_hoop():
	queue_free()
