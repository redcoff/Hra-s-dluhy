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

signal DialogSystemIndexUpdate
signal character_changed
signal all_texts_finished

var finished = false; #finished current sentence
var dialog_index = 0
var current_text = null #current block of texts. 
var text_index = 0
var dialog_done = false
var isMonolog = false

	
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
	
	var chapter = dialog.chapter
	var sceneName = dialog.level
	var character_name = dialog.texts[text_index].char
	var emotion = dialog.texts[text_index].emotion
	finished = false
	show_dialog(character_name, dialogSay[dialog_index], emotion)
	dialog_index += 1
	
func load_monolog(text):
	show_dialog("Marek", text)

func show_dialog(char_name, say, emotion = ""):
	visible = true
	set_character_image(char_name, emotion)
	$TextSpace/CharName.text = char_name
	$TextSpace/CharText.bbcode_text = say
	$TextSpace/CharText.percent_visible = 0
	$TextSpace/Tween.interpolate_property(
		$TextSpace/CharText, "percent_visible", 0, 1, 1, 
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

func set_character_image(name, emotion = ""):
	emit_signal("character_changed", name, emotion)

func finish_dialog():
	isMonolog = false
	dialog_done = true
	visible = false
	emit_signal("all_texts_finished")



func _on_HUD_start_dialog(text = null):
	if(text != null):
		dialog_done = false
		load_monolog(text)
		isMonolog = true
	else:
		text_index = 0
		dialog_index = 0
		dialog_done = false
		write_next_dialog()
