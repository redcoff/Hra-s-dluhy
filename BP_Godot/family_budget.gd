extends Node2D

signal start_dialog

var expenses = {
	"rent": 0,
	"energy": 0,
	"food": 0,
	"transport": 0,
	"clothes": 0,
	"freetime": 0,
}
var revenues = {
	"marek": 0,
	"petra": 0,
}

var to_pay = {
	"rent": 0,
	"energy": 0,
}

var used_total = 0
var rev_total = 0 # = 100 %

var suffix = " Kč"

var show_order
var order_index = 0
var current_show_node
var finished = true

var attempts = 0
var MAX_ATTEMPTS = 3

var GOOD_BUDGET = {
	"food": 10,
	"transport": 5,
	"freetime": 5,
	"clothes": 5,
	"save": 5
}
var regex = RegEx.new()

var parent
var done = false

func _ready():
	regex.compile("^[0-9]*$")
	parent = get_parent()
	set_revenues()
	emit_signal("start_dialog")
	show_order = [
		[$RevenuesContainer/RevenuesLabel],
		[$RevenuesContainer/MarekContainer/MarekNameLabel,
		$RevenuesContainer/MarekContainer/MarekRevLabel,
		$RevenuesContainer/PetraContainer/PetraNameLabel,
		$RevenuesContainer/PetraContainer/PetraRevLabel],
		[$TotalRevContainer/TotalRevNameLabel,
		$TotalRevContainer/TotalRevLabel],
		[$NeedToPayContainer/NeedToPayLabel],
		[$NeedToPayContainer/RentToPayContainer/RentToPayNameLabel,
		$NeedToPayContainer/RentToPayContainer/RentToPayLabel,
		$NeedToPayContainer/EnergyToPayContainer/EnergyToPayNameLabel,
		$NeedToPayContainer/EnergyToPayContainer/EnergyToPayLabel],
		[$ExpensesContainer/ExpensesLabel],
		[$ExpensesContainer/RentContainer/RentName, $ExpensesContainer/RentContainer/RentPercentage, $ExpensesContainer/RentContainer/RentLabel,
		$ExpensesContainer/EnergyContainer/EnergyName, $ExpensesContainer/EnergyContainer/EnergyPercentage, $ExpensesContainer/EnergyContainer/EnergyLabel],
		[$ExpensesContainer/FoodContainer/FoodName, $ExpensesContainer/FoodContainer/FoodPercentage, $ExpensesContainer/FoodContainer/FoodLabel],
		[$ExpensesContainer/TransportContainer/TransportName, $ExpensesContainer/TransportContainer/TransportPercentage, $ExpensesContainer/TransportContainer/TransportLabel],
		[$ExpensesContainer/ClothesContainer/ClothesName, $ExpensesContainer/ClothesContainer/ClothesPercentage, $ExpensesContainer/ClothesContainer/ClothesLabel],
		[$ExpensesContainer/FreetimeContainer/FreetimeName, $ExpensesContainer/FreetimeContainer/FreetimePercentage, $ExpensesContainer/FreetimeContainer/FreetimeLabel],
		[$TotalContainer/TotalLabel, $TotalContainer/AllPercentage_label],
		]
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		if not finished and order_index < show_order.size(): 
			for node in show_order[order_index]:
				if(node.percent_visible != 1):
					$Tween.remove_all()
					node.percent_visible = 1
			finished = true
			continue_showing()
	
func set_revenues():
	revenues["marek"] = 22000
	revenues["petra"] = 18000
	$RevenuesContainer/MarekContainer/MarekRevLabel.text = number_format(revenues["marek"]) + suffix
	$RevenuesContainer/PetraContainer/PetraRevLabel.text = number_format(revenues["petra"]) + suffix
	to_pay["rent"] = 14800
	to_pay["energy"] = 4000
	$NeedToPayContainer/RentToPayContainer/RentToPayLabel.text = number_format(to_pay["rent"]) + suffix
	$NeedToPayContainer/EnergyToPayContainer/EnergyToPayLabel.text = number_format(to_pay["energy"]) + suffix
	for value in revenues.values():
		rev_total += value
	$TotalRevContainer/TotalRevLabel.text = number_format(rev_total) + suffix
	

func number_format(number):
	var num_str = str(number)
	if num_str.length() > 3 and num_str.length() < 5:
		return num_str.insert(1, " ")
	elif num_str.length() >= 5:
		return num_str.insert(2, " ")
	return num_str

func calculate(end = false):
	used_total = 0
	if end:
		for value in GOOD_BUDGET.values():
			used_total += value
		used_total += value_to_percentage(to_pay["rent"])
		used_total += value_to_percentage(to_pay["energy"])
	else:
		for value in expenses.values():
			used_total += value
	var color_rgb_arr = calculate_color(used_total)
	$TotalContainer/AllPercentage_label.set("custom_colors/font_color", Color8(color_rgb_arr[0], color_rgb_arr[1], color_rgb_arr[2]))
	$TotalContainer/AllPercentage_label.text = str(used_total) + "% (" + str(percentage_to_value(used_total)) + suffix + ")"

func calculate_color(value):
	if value > 100:
		return [255, 0, 0]
	var hue = (1 - value/1000.0) * 1.2
	print("hue: " + str(hue))
	return calculate_hsl_to_rgb(hue, 1, 0.4)
	
func calculate_hsl_to_rgb(h, s, l):
	var r
	var g
	var b
	if s == 0:
		l = b 
		b = g 
		g = r
	else:
		var q
		if l < 0.5:
			q = l * (1 + s)
		else:
			q = (l + s) - (l * s)
		var p = float(2 * l) - q
		r = hue_to_rgb(p, q, h + 1/3.0)
		print("g: " + str(r))
		g = hue_to_rgb(p, q, h)
		print("r: " + str(g))
		b = hue_to_rgb(p, q, h - 1/3.0)
		print("b: " + str(b))
	return [round(r * 255), round(g * 255), round(b * 255), ]
		

func hue_to_rgb(p, q, t):
	if t < 0: t += 1
	if t > 1: t -= 1
	if t < 1/6.0: 
		return p +(q - p) * 6 * t
	if t < 1/2.0: 
		return q
	if t < 2/3.0:
		return p + (q - p) * (2/3.0 - t) * 6
	return p

func get_value_and_calculate(new_value, node_name):
	#node_name.erase(node_name.length() - 3, 3)
	expenses[node_name] = new_value
	print(expenses[node_name])
	calculate()
	
func calculate_money(node):
	var node_name = node.name
	node_name.erase(node_name.length() - 5, 5)
	node_name = node_name.to_lower()
	node.text = "(" + str(number_format(percentage_to_value(expenses[node_name]))) + suffix + ")"
	
func percentage_to_value(percentage):
	return rev_total/100 * percentage
	

func _on_RentUpButton_pressed():
	var cur_value = int($ExpensesContainer2/RentContainer/RentValue.text)
	$ExpensesContainer2/RentContainer/RentValue.text = str(cur_value + 1)
	calculate_money($ExpensesContainer2/RentContainer/RentLabel)
	
func _on_HUD_texts_finished():
	if order_index < show_order.size():
		for node in show_order[order_index]:
			current_show_node = node
			node.percent_visible = 0
			$Tween.interpolate_property(
				node, "percent_visible", 0, 1, 1, 
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
				)
			$Tween.start()
			finished = false
			yield($Tween, "tween_completed")
		finished = true
		continue_showing()
	else:
		$Done.visible = true
	if done:
		var canExit = Global.target_check($Done)
		if canExit: 
			parent.next_level()

func continue_showing():
	if order_index < show_order.size():
		order_index += 1
		if order_index == 3:
			$LineMarek.visible = true
			$LinePetra.visible = true  
		if order_index == 11:
			show_values()
		emit_signal("start_dialog")
	else:
		$Done.visible = true
	

func value_to_percentage(value):
	var w = value/float(rev_total)
	var v = w * 100
	return v
	#return float(value/rev_total * 100)

func _on_Done_pressed():
	$Done.release_focus()
	var failed = false
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

	if expenses["rent"] < value_to_percentage(to_pay["rent"]):
		answer.texts[0].say.append("Jak ale zaplatíme nájem? Víš o tom, že kdybychom nezaplatili celý nájem, tak nás můžou do třech měsíců vystěhovat?")
		failed = true
	if expenses["energy"] < value_to_percentage(to_pay["energy"]):
		answer.texts[0].say.append("Půlka domácnosti se skládá z chytrých spotřebičů, jak bych asi mohla prát, žehlit, vařit? A to bychom byli po tmě?")
		failed = true
	if expenses["food"] < GOOD_BUDGET["food"]:
		answer.texts[0].say.append("A co si jako představuješ, že budeme jíst? To tady budeme o hladu? Já bych přežila o vodě a chlebu, ale z toho si ani chleba nekoupíme.")
		failed = true
	if expenses["freetime"] < GOOD_BUDGET["freetime"]:
		answer.texts.append(
			{
				"char": "Marek",
				"emotion": "",
				"position": "left",
				"command": "",
				"say": ["No ale jak budu moct chodit do hospody, když nebudu mít na pivo žádné peníze? Však kvůli tomu jsem tohle celý nedělal."],
			}
		)
		failed = true
	if (rev_total - percentage_to_value(used_total)) < GOOD_BUDGET["save"]:
		answer.texts[0].say.append("Já nevím jak ty, ale moc se mi žít od výplatě k výplatě nechce. Myslím, že bychom si měli něco ušetřit.")
		failed = true
	if expenses["transport"] < GOOD_BUDGET["transport"]:
		answer.texts[0].say.append("Bez jízdenek se ale těžko dostanu do práce a děti do školy.")
		failed = true
	if expenses["clothes"] < GOOD_BUDGET["clothes"]:
		answer.texts[0].say.append("Ale děti rostou rychle a za chvíli nebudou moct co si obléct.")
		failed = true
	if percentage_to_value(used_total) > rev_total:
		answer.texts[0].say.append("To jsi roztřídil moc peněz! Kde tolik vezmeme?")
		failed = true
	if failed and attempts < MAX_ATTEMPTS:
		answer.texts[answer.texts.size()-1].say.append("Zkus to znovu...")
		attempts += 1
	elif failed:
		answer.texts.append(
			{
				"char": "Petra",
				"emotion": "",
				"position": "right",
				"command": "",
				"say": ["Ach jo, Máro, takhle to nepůjde.",
						"Koukej, pomůžu ti."],
			}
		)
		set_good_budget()
		done = true
	else: 
		answer.texts[0].say.append("To vypadá skvěle, Máro.")
		done = true
	emit_signal("start_dialog", answer)

	
func set_good_budget():
	for label in get_tree().get_nodes_in_group("expense"):
		var label_name = label.name.to_lower()
		label_name.erase(label_name.length() - 5, 5)
		
		if label_name == "rent" or label_name == "energy": 
			var percentage = round(value_to_percentage(to_pay[label_name]))
			label.set_text(str(percentage))
			label.text = str(percentage)
		else:
			label.text =  str(GOOD_BUDGET[label_name])
			expenses[label_name] = GOOD_BUDGET[label_name]
		label_name = label_name.capitalize()
		var node_label = label_name + "Label"
		calculate_money(get_node("ExpensesContainer/" + label_name + "Container/" + node_label))
	calculate()

func show_values():
	$ExpensesContainer/RentContainer/RentValue.visible = true
	$ExpensesContainer/EnergyContainer/EnergyValue.visible = true
	$ExpensesContainer/FoodContainer/FoodValue.visible = true
	$ExpensesContainer/TransportContainer/TransportValue.visible = true
	$ExpensesContainer/ClothesContainer/ClothesValue.visible = true
	$ExpensesContainer/FreetimeContainer/FreetimeValue.visible = true

var rent_text = ""
var energy_text = ""
var food_text = ""
var transport_text = ""
var clothes_text = ""
var freetime_text = ""

func handle_input(node, cached_text, new_text):
	if regex.search(new_text):
		node.text = new_text   
		cached_text = node.text
	else:
		node.text = cached_text
	node.set_cursor_position(node.text.length())

func _on_RentValue_text_changed(new_text):
	handle_input($ExpensesContainer/RentContainer/RentValue, rent_text, new_text)
	get_value_and_calculate(int($ExpensesContainer/RentContainer/RentValue.text), "rent")
	calculate_money($ExpensesContainer/RentContainer/RentLabel)


func _on_EnergyValue_text_changed(new_text):
	handle_input($ExpensesContainer/EnergyContainer/EnergyValue, energy_text, new_text)
	get_value_and_calculate(int($ExpensesContainer/EnergyContainer/EnergyValue.text), "energy")
	calculate_money($ExpensesContainer/EnergyContainer/EnergyLabel)


func _on_FoodValue_text_changed(new_text):
	handle_input($ExpensesContainer/FoodContainer/FoodValue, food_text, new_text)
	get_value_and_calculate(int($ExpensesContainer/FoodContainer/FoodValue.text), "food")
	calculate_money($ExpensesContainer/FoodContainer/FoodLabel)


func _on_TransportValue_text_changed(new_text):
	handle_input($ExpensesContainer/TransportContainer/TransportValue, transport_text, new_text)
	get_value_and_calculate(int($ExpensesContainer/TransportContainer/TransportValue.text), "transport")
	calculate_money($ExpensesContainer/TransportContainer/TransportLabel)


func _on_ClothesValue_text_changed(new_text):
	handle_input($ExpensesContainer/ClothesContainer/ClothesValue, clothes_text, new_text)
	get_value_and_calculate(int($ExpensesContainer/ClothesContainer/ClothesValue.text), "clothes")
	calculate_money($ExpensesContainer/ClothesContainer/ClothesLabel)


func _on_FreetimeValue_text_changed(new_text):
	handle_input($ExpensesContainer/FreetimeContainer/FreetimeValue, freetime_text, new_text)
	get_value_and_calculate(int($ExpensesContainer/FreetimeContainer/FreetimeValue.text), "freetime")
	calculate_money($ExpensesContainer/FreetimeContainer/FreetimeLabel)


