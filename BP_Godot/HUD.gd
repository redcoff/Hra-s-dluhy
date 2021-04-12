extends Control

signal texts_finished
signal start_dialog
signal set_environment

var current_quest = null
var parent
var wallet_built = false
var firstime_open = true
var micromenu_position


func _ready():
	$micromenu.visible = false
	current_quest = Global.get_next_quest()
	$micromenu/Wallet.visible = true
	parent = get_parent()
	
#todo predelat, hruza
func _process(delta):
	if Global.current_quest_target.empty():
		_on_quest_complete()


func _on_DialogBox_all_texts_finished():
	show_micromenu()
	emit_signal("texts_finished")


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
	if (!parent.has_node('Menu_wallet') and canTarget) or (!parent.has_node('Menu_wallet') and Global.chapter < 3):
		build_wallet()
	
func build_wallet():
	$micromenu/Wallet.hide()
	wallet_built = true
	firstime_open = false
	_on_start_dialog()
	var wallet_window = load("res://Menu_wallet.tscn").instance()
	wallet_window.connect("wallet_exit", self, "_on_wallet_exit")
	add_child(wallet_window)
	move_child(wallet_window, 2)

func _on_DialogBox_set_environment(par):
	emit_signal("set_environment", par)
	
func _on_wallet_exit():
	$micromenu/Wallet.show()
	if Global.chapter > 2: _on_start_dialog()


