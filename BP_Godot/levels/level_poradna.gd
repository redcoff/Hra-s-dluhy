extends Node2D

var parent 
signal start_dialog

func _ready():
	parent = get_parent()
	emit_signal("start_dialog")

func _on_HUD_texts_finished():
	Global.player_data.end = "GOOD_END"
	parent.start_fade("end")
