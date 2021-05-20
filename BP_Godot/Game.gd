extends Node

class_name LevelMachine

const DEBUG = true

var state: Object
export var levels : Array = [[null]];
var index = 0
var current_level

var history = []

func _ready():
	Sound.sound_node = $AudioSound
	Sound.music_node = $AudioMusic
	switch_level(levels[index], true)

func next_level():
	index += 1
	switch_level(levels[index], false)
	
func switch_level(new_level, is_initial):
	if(!is_initial): 
		remove_child(current_level) 
		current_level.disconnect("start_dialog",$HUD,"_on_Intro_start_dialog")
		$HUD.disconnect("texts_finished", current_level, "_on_HUD_texts_finished")
		current_level.disconnect("wallet_taken", $HUD, "_on_wallet_taken")
		$HUD.disconnect("set_environment",current_level,"_on_set_environment")
		hide_character_if_shown()
	var levelPath = new_level.get_path()
	current_level = load(levelPath).instance()
	print(current_level.name)
	$HUD.connect("set_environment",current_level,"_on_set_environment")
	Global.scene = current_level
	current_level.connect("start_dialog",$HUD,"_on_start_dialog")
	$HUD.connect("texts_finished", current_level, "_on_HUD_texts_finished")
	if current_level.name == "Level_obyvak":
		current_level.connect("wallet_taken", $HUD, "_on_wallet_taken")
	add_child(current_level)
	move_child(current_level, 0)
	$Transition/AnimationPlayerTransition.play("transition_in")

func hide_character_if_shown():
	if $HUD/Characters/Character.visible:
		$HUD/Characters/Character.hide()
	if $HUD/Characters/Character2.visible:
		$HUD/Characters/Character2.hide()

func back():
	if history.size() > 0:
		state = get_node(history.pop_back())

func start_fade(type):
	$FadeRect.show()
	$HUD/micromenu.hide()
	if type == 'end':
		$FadeRect/AnimationPlayer.play("Fade")
	if type == 'intro':
		$FadeRect/AnimationPlayer.play("FadeIntro")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'Fade':
		get_tree().change_scene("res://Outro.tscn")
	if anim_name == 'FadeIntro':
		$FadeRect.hide()
		

func skip_scenes(times):
	index += times


func _on_AudioSound_finished():
	Sound.audio_finished()
