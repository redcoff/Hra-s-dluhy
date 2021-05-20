extends Node2D

var intro_texts = ["[center]Všechny postavy, místa, názvy a stránky jsou fiktivní. Hra nemá za cíl nikomu škodit a podobnost s těmito reálnými a konrkétními prvky je náhodná.",
"[center]Hra je inspirována skutečnými událostmi.",
"[center]Mezerníkem můžete zrychlovat dialogy."]

var index = 0

func _ready():
	pass 

func _on_PlayButton_pressed():
	#get_tree().change_scene("res://levels/Game.tscn")
	$PlayButton.release_focus()
	$FadeRectBackground.show()
	$FadeRectBackground/EndText/AnimationPlayer.play("Fade")

func _on_CreditsButton_pressed():
	$CreditsButton.release_focus()
	var credits_scene = load("res://Credits.tscn").instance()
	add_child(credits_scene)

func _on_FadeRectBackground_animation_finished(anim_name):
	if intro_texts.size() > index and (anim_name != "fade_space"):
		$FadeRectBackground/EndText.bbcode_text = intro_texts[index]
		#if index == intro_texts.size() - 1:
		#	$FadeRectBackground/EndText/AnimationPlayerSpace.play("fade_space")
		$FadeRectBackground/EndText/AnimationPlayer.play("TextShowing")
		index += 1
	else:
		get_tree().change_scene("res://levels/Game.tscn")

func _on_TutorialButton_pressed():
	$CreditsButton.release_focus()
	var tutorial_scene = load("res://Tutorial.tscn").instance()
	add_child(tutorial_scene)
