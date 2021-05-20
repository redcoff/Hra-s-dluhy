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
	Sound.play_music("livingroom_music")
	#$Background.texture = load("res://assets/GFX/Background/obyvak/obyvak.png")


func _on_door_pressed():
	var canExit = Global.target_check($Background/Door)
	if canExit:
		Sound.play_sound("doors_sound")
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

func clicked_not_button(event, node):
	if (event is InputEventMouseButton && event.pressed):
		var canTarget = Global.target_check(node)
		if canTarget:
			Sound.play_sound("sofa_fall")
			Global.chapter += 1
			emit_signal("start_dialog")

func _on_Sofa_input_event(viewport, event, shape_idx):
	clicked_not_button(event, $Sofa)

func _on_HUD_texts_finished():
	if(Global.current_quest_target[0] == "Done"):
		parent.next_level()
		
	if(Global.current_quest_target[0] == "Sleep"):
		var can_exit = Global.target_check("Sleep")
		if can_exit: 
			Global.chapter += 1
			parent.next_level()

func _on_set_environment(par):
	if par == "obyvak_dark_light_on":
		Sound.play_sound("woman_ehmehm")
	$Background.texture = load("res://assets/GFX/Background/obyvak/" + par + ".png")

func _on_Photo_Kata_input_event(viewport, event, shape_idx):
	clicked_not_button(event, $Photo_Kata)

func _on_Photo_Simon_input_event(viewport, event, shape_idx):
	clicked_not_button(event, $Photo_Simon)

func _on_not_button_mouse_entered():
	Input.set_default_cursor_shape(16)

func _on_not_button_mouse_exited():
	Input.set_default_cursor_shape(0)
