extends Control

onready var music = $Music

func _ready():
	$Music.play()

func _on_Start_pressed():
	get_tree().change_scene("res://World/World.tscn")

func _on_Postjam_pressed():
	OS.shell_open("https://honieware.itch.io/board-sweepers")
