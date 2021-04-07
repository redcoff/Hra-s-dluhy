extends Control

#Poznámky ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Texty se nahrajou pouze jednou za celou hru a budou se držet tady a nikde jinde.
# Pro přístup k nějakému textu se použije signál.
# Při prvním načtení textu se načtou všechny texty a pak se čtou texty z paměti. 
# Když se přečte text, může se z paměti zas odendat..

# Struktura textů pro dialog:
# -------- (objekt)
# chapter
# jmeno_levelu	(blok textu, muze byt od ruznych postav)
#	char
#	say
#		[...]
#	emotion
# --------
# Když se spustí dialog, spustí se vždy jen aktuální objekt. Nikdy se nestane,
# že by bylo potřeba spustit více objektů po sobě!!!

signal character_changed
signal all_texts_finished
signal character_second_changed

var finished = false; #finished current sentence
var dialog_index = 0
var current_text = null #current block of texts. 
var text_index = 0
var dialog_done = false
var isMonolog = false


var cached_character = {
	"char": "",
	"emotion": "",
	"position": ""
}

var POSITION = {
	"center": [2.0, 2.0], 
	"left": [3, 2.0],
}
var OFFSET = 100
var POSITION_NAME= {
	"left": {
		"anchor": [0, 0],
		"margin": [30, 25, 0, 0],
		"grow_direction": [Control.GROW_DIRECTION_END, Control.GROW_DIRECTION_END]
	},
	"right": {
		"anchor": [1, 1],
		"margin": [0, 25, -30, 0],
		"grow_direction": [Control.GROW_DIRECTION_BEGIN, Control.GROW_DIRECTION_END]
	},
	"center": {
		"anchor": [0, 0],
		"margin": [30, 25, 0, 0],
		"grow_direction": [Control.GROW_DIRECTION_END, Control.GROW_DIRECTION_END]
	},
}
var CHAR_PER_SEC = 1/15.0


var pos

func _ready():
	$SpeakAudio1.stream = Sound.character_speak_sound_1
	$SpeakAudio2.stream = Sound.character_speak_sound_2
	$SpeakAudio3.stream = Sound.character_speak_sound_3
	
func _process(delta):
	$TextSpace/Next/NextButton.visible = finished
	if Input.is_action_just_pressed("ui_accept") and not dialog_done:
		if($TextSpace/CharText.percent_visible != 1):
			$TextSpace/Tween.stop_all()
			$TextSpace/CharText.percent_visible = 1
			finished = true
		else:   
			if not isMonolog:
				load_dialog(current_text)
			else:
				finish_dialog()
	
func write_next_dialog():
	current_text = Global.get_current_dialog() 
	if current_text != null :
		load_dialog(current_text)
	else:
		finish_dialog()
		return
	
func load_dialog(dialog):
	var dialogSay = dialog.texts[text_index].say
	if dialog_index >= dialogSay.size():
		text_index += 1
		if dialog.texts.size() == text_index:
			finish_dialog() 
			return
		else: 
			dialogSay = dialog.texts[text_index].say
			dialog_index = 0
	
	pos = dialog.texts[text_index].position
	var character_name = dialog.texts[text_index].char
	var emotion = dialog.texts[text_index].emotion
	var command = dialog.texts[text_index].command
	
	if command != null:
		apply_command(command)

	finished = false
	show_dialog(character_name, dialogSay[dialog_index], emotion)
	dialog_index += 1
	
	if(character_name != "..." and character_name != "Barman" and character_name != cached_character.char):
		cached_character.char = character_name
		cached_character.emotion = emotion
		cached_character.position = pos
	
func load_monolog(text):
	show_dialog("Marek", text)
	
	
#$Transition/AnimationPlayerTransition.play_backwards("transition_in")
#emit_signal("start_dialog")
#$Transition/AnimationPlayerTransition.play("transition_in")

func show_dialog(char_name, say, emotion = ""):
	var transition_anim = $Transition/AnimationPlayerTransition
	if char_name == "..." and !$Transition.visible:
		$Transition.visible = true
		transition_anim.play_backwards("transition_in")
		#yield( get_node("Transition/AnimationPlayerTransition"), "animation_finished" )
	elif char_name != "..." and $Transition.visible: 
		transition_anim.play("transition_in")
		#yield( get_node("Transition/AnimationPlayerTransition"), "animation_finished" )
		$Transition.visible = false
	visible = true

	if cached_character.char != "" and cached_character.char != char_name:
		set_second_character_image(cached_character.char, cached_character.emotion)
	
	if pos == "right":
		$TextSpace.texture = load("res://assets/GFX/HUD/text_spaceB.png")
	else:
		$TextSpace.texture = load("res://assets/GFX/HUD/text_spaceA.png")
	set_name_position()
	set_character_image(char_name, emotion)
	print("char1: " + get_parent().get_node("Character").get_child(0).texture.resource_path)
	print("char2(cache): " + get_parent().get_node("Character2").get_child(0).texture.resource_path)
	$TextSpace/CharName.text = char_name
	$TextSpace/CharText.bbcode_text = say
	$TextSpace/CharText.percent_visible = 0
	var text_duration = say.length() * CHAR_PER_SEC
	$TextSpace/Tween.interpolate_property(
		$TextSpace/CharText, "percent_visible", 0, 1, text_duration, 
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
	$TextSpace/Tween.start()
	

func _on_Tween_tween_completed(object, key):
	finished = true

func _on_NextButton_pressed():
	if not isMonolog:
		load_dialog(current_text)
	else:
		finish_dialog()
		
func set_second_character_image(name, emotion = ""):
	emit_signal("character_second_changed", name, emotion)

func set_character_image(name, emotion = ""):
	emit_signal("character_changed", name, emotion)

func finish_dialog():
	isMonolog = false
	dialog_done = true
	visible = false
	emit_signal("all_texts_finished")


func apply_command(command):
	if(command == "hide_cache"): get_parent().get_node("Character2").hide()
	

func _on_HUD_start_dialog(text = null):
	dialog_done = false
	if(text != null and text is String):
		load_monolog(text)
		isMonolog = true
	elif (text != null):
		current_text = text
		text_index = 0
		dialog_index = 0
		load_dialog(text)
	else:
		delete_cached_char()
		text_index = 0
		dialog_index = 0
		write_next_dialog()

func delete_cached_char():
	cached_character.char = ""
	cached_character.emotion = ""
	cached_character.position = ""

var switch = 0
var step_count = 0
var char_played_cache = 0

func _on_Tween_tween_step(object, key, elapsed, value):
	var char_step = $TextSpace/CharText.visible_characters
	step_count += 1
	
	#if step_count == 4: 
	if char_step % 2 and char_played_cache != char_step:
		$SpeakAudio1.play()
		char_played_cache = char_step
	elif char_played_cache != char_step:
		$SpeakAudio2.play()
		char_played_cache = char_step

func calculate_position(size, char_pos):
	var pos_x
	var pos_y
	if char_pos == "right":
		pos_x = (OS.get_screen_size().x - (OS.get_screen_size().x / POSITION["left"][0])) - (size.x/POSITION["left"][0])
		pos_y = (OS.get_screen_size().y /POSITION["left"][1])  - (size.y / POSITION["left"][1]) + OFFSET
	else:
		pos_x = (OS.get_screen_size().x / POSITION[char_pos][0]) - (size.x/POSITION[char_pos][0])
		pos_y = (OS.get_screen_size().y /POSITION[char_pos][1])  - (size.y / POSITION[char_pos][1]) + OFFSET
	return Vector2(pos_x, pos_y)

func _on_Character_character_image_changed(size):
	var node = get_parent().get_node("Character")
	node.position = calculate_position(size, pos)

func _on_Character2_character_second_image_changed(size):
	var node = get_parent().get_node("Character2")
	node.position = calculate_position(size, cached_character.position)

func set_name_position():
	$TextSpace/CharName.anchor_left = POSITION_NAME[pos].anchor[0]
	$TextSpace/CharName.anchor_right = POSITION_NAME[pos].anchor[1]
	$TextSpace/CharName.margin_left = POSITION_NAME[pos].margin[0]
	$TextSpace/CharName.margin_top = POSITION_NAME[pos].margin[1]
	$TextSpace/CharName.margin_right = POSITION_NAME[pos].margin[2]
	$TextSpace/CharName.margin_bottom= POSITION_NAME[pos].margin[3]
	$TextSpace/CharName.grow_horizontal = POSITION_NAME[pos].grow_direction[0]
	$TextSpace/CharName.grow_vertical = POSITION_NAME[pos].grow_direction[1]
