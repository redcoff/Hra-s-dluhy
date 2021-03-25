extends Node

signal UpdateQuest

var dialogSystemIndex : int = 0
var chapter : int = 0
var level : String = ""
var texts
var quests
var scene
var current_cash = 2000
var current_quest_target
var bad_target_texts

func _ready():
	texts = get_dialog_file('dialogs/dialogs.json')
	quests = get_dialog_file('dialogs/quests.json')
	bad_target_texts = get_dialog_file('dialogs/monologs.json')

func update_dialogSystemIndex():
	dialogSystemIndex += 1
	emit_signal("DialogSystemIndexUpdate")
	
func get_dialogSystemIndex() -> int:
	return dialogSystemIndex

func update_chapter():
	chapter += 1
	emit_signal("ChapterUpdate")
	
func get_chapter() -> int:
	return chapter
	
func get_level() -> String:
	return level

func update_level(new_level):
	level = new_level
	emit_signal("LevelUpdate")

func get_dialog_file(filename):
	var file = File.new()
	file.open(filename, File.READ)
	var text = file.get_as_text()
	var data = parse_json(text)
	file.close()
	#print(data)
	return data
	
func get_current_dialog():
	if not texts.empty():
		print(texts[0].level)
		print(scene.name)
		if texts[0].chapter == chapter and texts[0].level == scene.name:
			return texts.pop_front() 

func get_next_quest():
	# menit questy by se mohlo, pokud jsou target prazdne, nez pres signal, aby se to splnilo.
	if not quests.empty():
		current_quest_target = quests[0].target
	return quests.pop_front()
	
func get_certain_bad_target_text(bad_target):
	if bad_target in bad_target_texts:
		var texts_arr = bad_target_texts[bad_target]
		if not texts_arr.empty():
			var rng = RandomNumberGenerator.new()
			rng.randomize()
			var rn_num = rng.randi_range(0, texts_arr.size()-1)
			print(texts_arr[rn_num])
			return texts_arr[rn_num]
	
func pop_good_target():
	if not current_quest_target.empty():
		current_quest_target.pop_front()
		
func target_check(curr_target):
	curr_target.release_focus()
	print(curr_target.name)
	print(current_quest_target[0])
	if curr_target.name != current_quest_target[0]:
		var text = get_certain_bad_target_text(curr_target.name)
		print(curr_target.get_owner().name)
		curr_target.get_owner().emit_signal("start_dialog", text)
		return false
	Global.pop_good_target()
	return true
