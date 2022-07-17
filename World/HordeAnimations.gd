extends Node2D

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

signal spawn_new_horde

func _ready():
	animationTree.active = true

func _on_HordeHandler_new_horde():
	print("Wowowowowow new horde !!")
	animationState.travel("Defeated")

func spawn_new_horde():
	emit_signal("spawn_new_horde")
	animationState.travel("RESET")
