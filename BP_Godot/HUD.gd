extends Control

signal texts_finished
signal start_dialog
signal set_environment

var current_quest = null
var parent
var wallet_built = false
var firstime_open = true
var micromenu_position

var cached_wallet


func _ready():
	$micromenu.visible = false
	current_quest = Global.get_next_quest()
	$micromenu/Wallet.visible = false
	parent = get_parent()
	
#todo predelat, hruza
func _process(delta):
	if Global.current_quest_target.empty():
		_on_quest_complete()


func _on_DialogBox_all_texts_finished():
	show_micromenu()
	emit_signal("texts_finished")
	
	if has_node('Decision'):
		hide_micromenu()
	
	if has_node('Execution'):
		var node = get_node('Execution')
		if node.failed or node.success:
			node.queue_free()
			Global.target_check("Exe_done")
			_on_start_dialog()


func _on_start_dialog(text = null):
	hide_micromenu() 
	emit_signal("start_dialog", text)
	
func _on_wallet_taken():
	show_wallet_ui()
	
func show_wallet_ui():
	$micromenu/Wallet.visible = true
	
func parse_quest():
	if(current_quest != null):
		#var quest_chapter = current_quest.chapter
		var quest_name = current_quest.quest_name
		#var quest_level = current_quest.level
		#var quest_target = current_quest.target
		return quest_name
	return ""

func _on_quest_complete():
	current_quest = Global.get_next_quest()
	$micromenu/QuestContainer/QuestNameLabel.text = parse_quest()
	

func show_micromenu():          
	$micromenu.visible = true
	#micromenu_position = $micromenu.rect_position
	$micromenu/QuestContainer/QuestNameLabel.text = parse_quest()
	#$AnimationPlayerMicromenu.play("show_microbar")
	#yield($AnimationPlayerMicromenu, "animation_finished" )
	
func hide_micromenu():
	#$AnimationPlayerMicromenu.play_backwards("show_microbar")
	#yield($AnimationPlayerMicromenu, "animation_finished" )
	#$micromenu.rect_position = micromenu_position
	$micromenu.visible = false


func _on_penezenka_pressed():
	var canTarget = Global.target_check($micromenu/Wallet)
	if (!parent.has_node('Menu_wallet') and canTarget) or ((!parent.has_node('Menu_wallet') and Global.chapter < 3 and Global.current_quest_target[0] != "Clock")):
		build_wallet()
	
func build_wallet():
	wallet_built = true
	firstime_open = false
	$micromenu/Wallet.hide()
	if (Global.chapter == 4 and Global.got_loan) or Global.chapter == 6:
		add_child(cached_wallet)
		move_child(cached_wallet, 2)
		if Global.chapter == 4: cached_wallet.update_revs()
		if Global.chapter == 6: cached_wallet.set_loan_payment()
	else:
		_on_start_dialog()
		var wallet_window = load("res://Menu_wallet.tscn").instance()
		wallet_window.connect("wallet_exit", self, "_on_wallet_exit")
		cached_wallet = wallet_window
		add_child(wallet_window)
		move_child(wallet_window, 1)

func build_letter():
	var letter_window = load("res://Letter.tscn").instance()
	letter_window.connect("letter_closed", self, "_on_letter_closed")
	add_child(letter_window)
	move_child(letter_window, 2)

func _on_DialogBox_set_environment(par):
	emit_signal("set_environment", par)
	
func _on_wallet_exit():
	$micromenu/Wallet.show()
	if Global.chapter > 2: _on_start_dialog()

func _on_letter_closed():
	_on_start_dialog()

func build_decision(decision):
	var index_position = 2 
	var decision_window = load("res://Decision.tscn").instance()
	decision_window.connect("decision_picked", self, "_on_decision_picked")
	decision_window.set_decisions(decision)
	add_child(decision_window)
	if !parent.has_node('Execution'):
		index_position = 4
	move_child(decision_window, index_position)

func _on_decision_picked(decision):
	if decision == "pass":
		if has_node('Execution'):
			var node = get_node('Execution')
			node.queue_free()
			Global.skip_dialog(1)
			Global.skip_quest(1)
			Global.player_data.say_nothing_to_executor = true
		else:
			Global.skip_dialog(3)
			parent.skip_scenes(4)
			_on_quest_complete()
			
	_on_start_dialog()

func build_execution():
	var execution_window = load("res://Execution.tscn").instance()
	#execution_window.connect("decision_picked", self, "_on_decision_picked")
	#execution_window.set_decisions(decision)
	add_child(execution_window)
	move_child(execution_window, 1)


func _on_Credits_pressed():
	$micromenu/Credits.hide()
	$micromenu/Credits.release_focus()
	var credits_scene = load("res://Credits.tscn").instance()
	parent.add_child(credits_scene)


func _on_Sound_pressed():
	if Sound.enabled:
		Sound.sound_off()
		$micromenu/Sound.texture_normal = load("res://assets/GFX/Environment/Micromenu/sound_off.png")
	else:
		Sound.sound_on()
		$micromenu/Sound.texture_normal = load("res://assets/GFX/Environment/Micromenu/sound_on.png")


func _on_Tutorial_pressed():
	$micromenu/Tutorial.hide()
	$micromenu/Tutorial.release_focus()
	var credits_scene = load("res://Tutorial.tscn").instance()
	parent.add_child(credits_scene)
