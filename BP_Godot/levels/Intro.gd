extends Node2D

signal start_dialog

var parent 

func _ready():
	parent = get_parent()
	parent.start_fade('intro')
	emit_signal("start_dialog")
	Sound.play_music("intro_music")
	

func enter():
	print("Jsem v intru!")
	yield(get_tree().create_timer(2.0), "timeout")
	#exit()

func exit():
	parent.next_level()

func _on_door_pressed():
	print('du do obyvaku!');
	exit()


func _on_HUD_texts_finished():
	parent.next_level()
