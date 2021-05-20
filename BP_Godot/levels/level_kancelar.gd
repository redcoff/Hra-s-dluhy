extends Node2D

signal start_dialog

var parent

func _ready():
	Sound.play_music("office")
	parent = get_parent()
	emit_signal("start_dialog")


func _on_HUD_texts_finished():
	Global.player_data.go_to_creditor = true
	parent.next_level()
