extends Node2D

signal start_dialog
signal wallet_taken
signal quest_complete

var parent 
var hasWallet = false
var canExit = false

func _ready():
	parent = get_parent()
	print("obyvak startuje dialog")
	emit_signal("start_dialog")

func enter():
	print("Jsem v obýváku!")
	yield(get_tree().create_timer(2.0), "timeout")
	#exit()

func _on_door_pressed():
	var canExit = Global.target_check($Background/Door)
	if canExit:
		parent.next_level()


func _on_Wallet_pressed():
	var canTake = Global.target_check($Wallet)
	if canTake:
		hasWallet = true
		print("beru penezenku")
		emit_signal("wallet_taken")
		emit_signal("start_dialog")
		$Wallet.queue_free()


func _on_notebook_pressed():
	Global.target_check($Background/Notebook)

