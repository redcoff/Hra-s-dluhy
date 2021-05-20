extends Node2D

var parent
var MAX_ATTEMPTS = 3
var attempts = 0
var failed = false
var good_things_marked = {
	"rings": false,
	"bed": false,
	"toy": false,
}
var success = false

var answer = {
		"texts": 
		[
			{
				"char": "Marek",
				"emotion": "",
				"position": "left",
				"command": "",
				"say": [],
			}
		]
	}

func _ready():
	parent = get_parent()

func reset_answer():
	answer = {
		"texts": 
		[
			{
				"char": "Marek",
				"emotion": "",
				"position": "left",
				"command": "",
				"say": [],
			}
		]
	}

func _on_Rings_pressed():
	$BlurRect/Rings.texture_normal = load("res://assets/GFX/Items/Execution/rings.png")
	good_things_marked.rings = true
	reset_answer()
	$BlurRect/Rings.release_focus()
	answer.texts[0].say.append("Jsem si jistý, že snubní prstýnky exekutor vzít nemůže!")
	check_all_good_marked()
	parent.emit_signal("start_dialog", answer)


func _on_Tv_pressed():
	attempts += 1
	reset_answer()
	$BlurRect/Tv.release_focus()
	answer.texts[0].say.append("Že by exekutor nemohl zabavit televizi?")
	answer.texts[0].say.append("Hm, to asi spíš může...")
	check_max_attempts()
	parent.emit_signal("start_dialog", answer)


func _on_Ps_pressed():
	attempts += 1
	reset_answer()
	$BlurRect/Ps.release_focus()
	answer.texts[0].say.append("Plejstejšn! To přece nemůže vzít!")
	answer.texts.append(
			{
				"char": "Exekutor",
				"emotion": "",
				"position": "right",
				"command": "",
				"say": ["..."],
			}
		)
	answer.texts.append(
			{
				"char": "Marek",
				"emotion": "",
				"position": "left",
				"command": "",
				"say": ["Tak asi může..."],
			}
		)
	check_max_attempts()
	parent.emit_signal("start_dialog", answer)


func _on_Toy_pressed():
	$BlurRect/Toy.texture_normal = load("res://assets/GFX/Items/Execution/toy.png")
	good_things_marked.toy = true
	reset_answer()
	$BlurRect/Toy.release_focus()
	answer.texts[0].say.append("Šimonův plyšák! Ten exekutor vzít nesmí!")
	check_all_good_marked()
	parent.emit_signal("start_dialog", answer)


func _on_Bed_pressed():
	$BlurRect/Bed.texture_normal = load("res://assets/GFX/Items/Execution/bed.png")
	good_things_marked.bed = true
	reset_answer()
	$BlurRect/Bed.release_focus()
	answer.texts[0].say.append("Postel patří k základním věcím pro náš život.")
	answer.texts[0].say.append("Tu exekutor vzít nemůže.")
	check_all_good_marked()
	parent.emit_signal("start_dialog", answer)


func _on_Paint_pressed():
	attempts += 1
	reset_answer()
	$BlurRect/Paint.release_focus()
	answer.texts[0].say.append("Náš obraz!")
	answer.texts[0].say.append("Ale ten nám exekutor asi vzít může...")
	check_max_attempts()
	parent.emit_signal("start_dialog", answer)

func check_max_attempts():
	if attempts == MAX_ATTEMPTS:
		answer.texts.append(
			{
				"char": "Exekutor",
				"emotion": "",
				"position": "right",
				"command": "",
				"say": ["Jste tady jenom pro smích!", "Nemám už na vás čas."],
			}
		)
		failed = true

func check_all_good_marked():
	for thing in good_things_marked:
		if good_things_marked[thing] == false:
			return
	answer.texts.append(
			{
				"char": "Marek",
				"emotion": "",
				"position": "left",
				"command": "",
				"say": ["Tyhlety věci nám nemůžete zabavit!"],
			}
		)
	answer.texts.append(
			{
				"char": "Exekutor",
				"emotion": "",
				"position": "right",
				"command": "",
				"say": ["Fajn, tak si je nechte."],
			}
		)
	success = true
