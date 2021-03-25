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

func _on_domu_pressed():
	exit($Buttons/Domu)


func _on_dvere_pressed():
	exit($Background/Door)


func _on_do_prace_pressed():
	exit($Buttons/Prace)
