extends Node

var chapter : int = 0
var level : String = ""
var texts
var quests
var scene
var current_cash = 2000
var current_quest_target
var bad_target_texts
var hasWallet = false
var got_loan = false

var player_data = {
	"sound": true,
	"go_to_creditor": false,
	"say_nothing_to_executor": false,
	"end": ""
}

var ENVIRONMENT = ""
var LOAN_PAYMENT = 8279
var FIRST_PAYMENT = 11479

var expenses = {
	"rent": 14800,
	"energy": 4000,
	"food": 4000,
	"transport": 2000,
	"clothes": 2000,
	"freetime": 2000,
	"loan": LOAN_PAYMENT
}
var revenues = {
	"marek": 22000,
	"petra": 18000,
	"save": 4000,
	"loan": 0,
}


func _ready():
	ENVIRONMENT = OS.get_name()
	texts = get_dialog_file("res://dialogs/dialogs.json")
	quests = get_dialog_file("res://dialogs/quests.json")
	bad_target_texts = get_dialog_file("res://dialogs/monologs.json")

func get_dialog_file(filename):
	var file = File.new()
	file.open(filename, File.READ)
	var text = file.get_as_text()
	var data = parse_json(text)
	file.close()
	return data
	
func get_current_dialog():
	if not texts.empty():
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
			return texts_arr[rn_num]
	
func pop_good_target():
	if not current_quest_target.empty():
		current_quest_target.pop_front()
		
func target_check(curr_target):
	if curr_target is String:    
		if curr_target == current_quest_target[0]:
			Global.pop_good_target()
			return true
		return false
	if curr_target.get_class() != "Area2D":
		curr_target.release_focus()
	if curr_target.name != current_quest_target[0]:
		var text = get_certain_bad_target_text(curr_target.name)
		curr_target.get_owner().emit_signal("start_dialog", text)
		return false
	Global.pop_good_target()
	return true

func skip_dialog(times):
	for i in range(0, times):
		texts.pop_front() 
		
func skip_quest(times):
	for i in range(0, times):
		current_quest_target.clear()

