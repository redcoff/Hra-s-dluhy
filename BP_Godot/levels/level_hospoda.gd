extends Node2D

var parent 
signal start_dialog

func _ready():
	parent = get_parent()
	emit_signal("start_dialog")
	Sound.play_music("pub")

func _on_Door_pressed():
	var canExit = Global.target_check($Background/Door)
	if canExit:
		Sound.play_sound("doors_open")
		parent.next_level()

func _on_Clock_pressed():
	var toTrigger = Global.target_check($Background/Clock)
	if toTrigger:
		emit_signal("start_dialog")
		
func _on_HUD_texts_finished():
	pass

func _on_set_environment(par):
	$Background/Clock.texture_normal = load("res://assets/GFX/Background/hospoda/" + str(par) + ".png")
