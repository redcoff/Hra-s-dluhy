extends Node2D


var parent 
signal start_dialog

func _ready():
	parent = get_parent()
	emit_signal("start_dialog")
	Sound.play_music("office")

func _on_HUD_texts_finished():
	parent.next_level()

func _on_set_environment(par):
	Sound.play_sound("boom")
	$Background.texture = load("res://assets/GFX/Background/" + par + ".png")
