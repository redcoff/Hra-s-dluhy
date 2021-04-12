extends Node2D

signal start_dialog
signal wallet_taken
signal quest_complete

var parent 
var canExit = false

func _ready():
	parent = get_parent()
	emit_signal("start_dialog")
	if Global.hasWallet: $Wallet.queue_free()
	#$Background.texture = load("res://assets/GFX/Background/obyvak/obyvak.png")

func _on_door_pressed():
	var canExit = Global.target_check($Background/Door)
	if canExit:
		parent.next_level()

func _on_Wallet_pressed():
	var canTake = Global.target_check($Wallet)
	if canTake:
		Global.hasWallet = true
		emit_signal("wallet_taken")
		emit_signal("start_dialog")
		$Wallet.queue_free()

func _on_notebook_pressed():
	var canTarget = Global.target_check($Background/Notebook)
	if canTarget:
		parent.next_level()

func _on_Sofa_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		var canTarget = Global.target_check($Sofa)
		if canTarget:
			Global.chapter += 1
			emit_signal("start_dialog")

func _on_HUD_texts_finished():
	if(Global.current_quest_target[0] == "Done"):
		parent.next_level()
		
	if(Global.current_quest_target[0] == "Sleep"):
		var can_exit = Global.target_check("Sleep")
		if can_exit: 
			Global.chapter += 1
			parent.next_level()
		

func _on_set_environment(par):
	$Background.texture = load("res://assets/GFX/Background/obyvak/" + par + ".png")
	
func _on_Sofa_mouse_entered():
	Input.set_default_cursor_shape(2)

func _on_Sofa_mouse_exited():
	Input.set_default_cursor_shape(0)
