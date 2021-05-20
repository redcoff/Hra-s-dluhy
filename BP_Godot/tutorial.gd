extends Node2D

var parent
var hud_game

func _ready():
	parent = get_parent()
	if parent.has_node("HUD"):
		$pseudoHUD.hide()
		hud_game = parent.get_node("HUD")

func _on_Exit_pressed():
	if hud_game != null:
		hud_game.get_node("micromenu/Tutorial").show()
	queue_free()

