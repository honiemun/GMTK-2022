extends KinematicBody2D

onready var dice = get_parent().get_node("Dice")

func _on_Hurtbox_area_entered(_area):
	dice.add_to_dice(3)
	queue_free()
