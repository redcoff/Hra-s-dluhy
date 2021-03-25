extends Node2D

var parent 
signal start_dialog

func _ready():
	parent = get_parent()
	emit_signal("start_dialog")

func exit(node):
	var canExit = Global.target_check(node)
	if canExit:
		parent.next_level()

func _on_Door_pressed():
	var canExit = Global.target_check($Background/Door)
	if canExit:
		parent.next_level()


func _on_Clock_pressed():
	var toTrigger = Global.target_check($Background/Clock)
	if toTrigger:
		pass
