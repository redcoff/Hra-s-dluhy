extends Node2D

var parent
var hud

func _ready():
	parent = get_parent()
	if parent.has_node("HUD"):
		hud = parent.get_node("HUD")
		

func _on_ExitButton_pressed():
	if hud != null:
		hud.get_node("micromenu/Credits").show()
	queue_free()
	
