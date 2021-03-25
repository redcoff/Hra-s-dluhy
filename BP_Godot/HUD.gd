extends Control

signal texts_finished
signal start_dialog

var current_quest = null
var parent
var wallet_built = false
var firstime_open = true
var micromenu_position

func _ready():
	$micromenu.visible = false
	current_quest = Global.get_next_quest() #very first quest
	$micromenu/Wallet.visible = false
	parent = get_parent()
	
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
	Global.target_check($micromenu/Wallet)
	if !parent.has_node('menu_wallet'):
		build_wallet()
	
func build_wallet():
	wallet_built = true
	firstime_open = false
	_on_start_dialog()
	var wallet_window = load("res://menu_wallet.tscn").instance()
	parent.add_child(wallet_window)
	parent.move_child(wallet_window, 1)
