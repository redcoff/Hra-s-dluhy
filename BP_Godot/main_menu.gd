extends Node2D



func _ready():
	pass 



func _on_PlayButton_pressed():
	get_tree().change_scene("res://levels/Game.tscn")


func _on_CreditsButton_pressed():
	var credits_scene = load("res://Credits.tscn").instance()
	add_child(credits_scene)
