extends Node2D

onready var text = $Control/RichTextLabel

func _ready():
	init(100)
	
func init(points):
	text.set_bbcode(str("[center]Game over, you have ", points, " points.[/center]"))


func _on_Timer_timeout():
	get_tree().change_scene("res://world/World.tscn")
