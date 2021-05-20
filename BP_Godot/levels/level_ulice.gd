extends Node2D

var parent 
signal start_dialog

func _ready():
	parent = get_parent()
	emit_signal("start_dialog")
	Sound.play_music("street_day")
	
	if Global.chapter == 8:
		$Buttons/Prace.hide()
		$Buttons/Creditor.show()

func exit(node):
	var canExit = Global.target_check(node)
	if canExit:
		parent.next_level()

func _on_domu_pressed():
	var canExit = Global.target_check($Buttons/Domu)
	if canExit:
		if Global.chapter == 0:
			Sound.play_sound("doors_sound")
		parent.next_level()


func _on_dvere_pressed():
	var canExit = Global.target_check($Background/Door)
	if canExit:
		if Global.chapter == 0:
			Sound.play_sound("doors_open")
		parent.next_level()


func _on_do_prace_pressed():
	exit($Buttons/Prace)
	
func _on_set_environment(par):
	$Background.texture = load("res://assets/GFX/Background/ulice/" + par + ".png")

func clicked_not_button(event, node):
	if (event is InputEventMouseButton && event.pressed):
		var canTarget = Global.target_check(node)
		if canTarget:
			Global.chapter += 1
			emit_signal("start_dialog")

func _on_Bicycle_input_event(viewport, event, shape_idx):
	clicked_not_button(event, $Bicycle)

func _on_HUD_texts_finished():
	if Global.chapter == 8 and Global.player_data.go_to_creditor:
		parent.next_level()

func _on_not_button_mouse_entered():
	Input.set_default_cursor_shape(16)


func _on_not_button_mouse_exited():
	Input.set_default_cursor_shape(0)


func _on_Bottle_input_event(viewport, event, shape_idx):
	clicked_not_button(event, $Bottle)


func _on_Bin_input_event(viewport, event, shape_idx):
	clicked_not_button(event, $Bin)


func _on_Paper_input_event(viewport, event, shape_idx):
	clicked_not_button(event, $Paper)


func _on_Sign_input_event(viewport, event, shape_idx):
	clicked_not_button(event, $Sign)


func _on_Bar_input_event(viewport, event, shape_idx):
	clicked_not_button(event, $Bar)


func _on_Creditor_pressed():
	exit($Buttons/Creditor)
