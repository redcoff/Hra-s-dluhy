extends Node2D

signal start_dialog

func _ready():
	emit_signal("start_dialog")


func _on_BezPoplatkuALevneButton_pressed():
	$BlurRect.show()
	$Button.show()
	$PageContainer/PageRect.texture = load("res://assets/GFX/Environment/WebPages/BezPoplatkuALevnePage.png")
	$PageContainer.show()


func _on_NekrademeButton_pressed():
	$BlurRect.show()
	$Button.show()
	$PageContainer/PageRect.texture = load("res://assets/GFX/Environment/WebPages/Nekrademe.png")
	$PageContainer.show()

func _on_AlfaBetaButton_pressed():
	$BlurRect.show()
	$Button.show()
	$PageContainer/PageRect.texture = load("res://assets/GFX/Environment/WebPages/AlfaBeta.png")
	$PageContainer.show()


func _on_Button_pressed():
	$BlurRect.hide()
	$Button.hide()
	$PageContainer.hide()


func _on_Loan_pressed():
	var answer = {
		"texts": 
		[
			{
				"char": "Petra",
				"emotion": "",
				"position": "right",
				"command": "",
				"say": [],
			}
		]
	}
	emit_signal("start_dialog")
