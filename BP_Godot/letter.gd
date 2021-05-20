extends Node2D

signal letter_closed

func _ready():
	pass # Replace with function body.


func _on_Read_pressed():
	Global.target_check($Background/Read)
	queue_free()
	emit_signal("letter_closed")


func _on_Letter_pressed():
	Sound.play_sound("turn_page")
	$Background/Letter.hide()
	$Background/LetterOpen.show()
	$Background/Read.show()
