extends Node2D

signal wallet_exit

var parent
var suffix = " Kč"
var actual_budget = {
	"rent": 0,
	"energy": 0,
	"food": 0,
	"transport": 0,
	"clothes": 0,
	"freetime": 0,
}

var part_cash_plus = 500
var PART_CASH_MINUS = 500
var main_paied = false
var got_loan = false

func _ready():
	main_paied = false
	parent = get_parent()
	Global.revenues["marek"] = 0
	
	if Global.chapter > 2:
		$FinanceContainer/RevenuesContainer.show()
		$ExpensesContainer.show()
		$Button.disabled = true
		
		if Global.chapter > 4:
			Global.revenues["rent"] += 1000
		
		for rev in Global.revenues:
			Global.current_cash += Global.revenues[rev]
		Global.revenues["save"] = 0
		$ExpensesContainer.show()
		set_family_budget()
		set_family_revenues()
		$CashContainer/CashLabel.text = "Dohromady: "
	
	if Global.chapter > 4 and got_loan:
		$LoansContainer.show()
	update_total_cash()

func update_total_cash():
	if Global.current_cash < 0:
		Global.current_cash = 0
	$CashContainer/CashValueLabel.text = str(number_format(Global.current_cash))

func set_family_revenues():
	$FinanceContainer/RevenuesContainer/MarekContainer/MarekValue.text = str(number_format(Global.revenues["marek"])) + suffix
	$FinanceContainer/RevenuesContainer/PetraContainer/PetraValue.text = str(number_format(Global.revenues["petra"])) + suffix

func set_family_budget():
	for node in get_tree().get_nodes_in_group("wallet_expenses"):
		var node_name = node.name
		node_name.erase(node_name.length() - 5, 5)
		node.text = str(number_format(Global.expenses[node_name.to_lower()])) + suffix
		
func reset_remaining_expenses():
	for node in get_tree().get_nodes_in_group("wallet_expenses"):
		var node_name = node.name
		node_name.erase(node_name.length() - 5, 5)
		if node_name != "Rent" and node_name != "Energy": 
			node.text = str(number_format(actual_budget[node_name.to_lower()])) + suffix

func number_format(number):
	var num_str = str(number)
	if num_str.length() > 3 and num_str.length() < 5:
		return num_str.insert(1, " ")
	elif num_str.length() >= 5:
		return num_str.insert(2, " ")
	return num_str

func _on_Button_pressed():
	queue_free()
	emit_signal("wallet_exit")
	if Global.chapter >= 3: Global.target_check("Paied")

func pay_expense(node_button, exp_name, node_label):
	node_button.release_focus()
	if Global.current_cash >= Global.expenses[exp_name]:
		if node_button.disabled: node_button.disabled = false
		Global.current_cash -= Global.expenses[exp_name]
		node_label.text = "Zaplaceno."
		node_label.set("custom_colors/font_color",Color8(255,204,102))
		update_total_cash()
		node_button.hide()
	else:
		parent.emit_signal("start_dialog")
		$Button.disabled = false
		node_button.disabled = true
		
func add_to_expense(exp_name, node_value):
	if Global.current_cash < part_cash_plus:
		part_cash_plus = Global.current_cash
	else:
		part_cash_plus = 500
	if Global.current_cash > 0:
		actual_budget[exp_name] += part_cash_plus
		node_value.text = str(actual_budget[exp_name]) + suffix
		Global.current_cash -= PART_CASH_MINUS
		update_total_cash()

func deduct_from_expense(exp_name, node_value):
	if actual_budget[exp_name] >= PART_CASH_MINUS:
		actual_budget[exp_name] -= PART_CASH_MINUS
		Global.current_cash += PART_CASH_MINUS
	elif actual_budget[exp_name] >= 0:
		Global.current_cash += actual_budget[exp_name]
		actual_budget[exp_name] -= actual_budget[exp_name]
	node_value.text = str(actual_budget[exp_name]) + suffix
	update_total_cash()
	
func set_after_main_paied():
	if main_paied:
		if Global.chapter == 3:
			parent.emit_signal("start_dialog")
			reset_remaining_expenses()
			enable_certain_expense("Food")
	else: 
		main_paied = true

func enable_certain_expense(ex_name):
	for node in get_tree().get_nodes_in_group("expenses_button"):
		node.disabled = false
		node.show()
		print(node.name)
		if not ex_name in node.name: 
			node.disabled = true
		else:
			node.remove_from_group("expenses_button")

func _on_PayRentButton_pressed():
	pay_expense($ExpensesContainer/RentContainer/PayRentButton, 
	"rent", 
	$ExpensesContainer/RentContainer/RentValue)
	#if Global.chapter > 2:
	set_after_main_paied()
			

func _on_PayEnergyButton_pressed():
	pay_expense($ExpensesContainer/EnergyContainer/PayEnergyButton, 
	"energy",
	$ExpensesContainer/EnergyContainer/EnergyValue)
	if Global.chapter == 3:
		if main_paied:
			set_after_main_paied()
			
func pay_remaining(node_button, node_label, node_plus, node_minus):
	node_button.release_focus()
	node_label.set("custom_colors/font_color",Color8(255,204,102))
	node_button.hide()
	node_plus.hide()
	node_minus.hide()
	
func _on_PayFoodButton_pressed():
	if actual_budget["food"] > 2000:
		pay_remaining($ExpensesContainer/FoodContainer/PayFoodButton, 
		$ExpensesContainer/FoodContainer/FoodValue,
		$ExpensesContainer/FoodContainer/PayFoodButtonPlus,
		$ExpensesContainer/FoodContainer/PayFoodButtonMinus)
		enable_certain_expense("Transport")
	else:
		$ExpensesContainer/FoodContainer/PayFoodButton.release_focus()
		var answer = {
		"texts": 
		[
			{
				"char": "Marek",
				"emotion": "",
				"position": "left",
				"command": "",
				"say": ["Měl bych do jídla dát víc peněz, tohle nám na celý měsíc nevystačí..."],
			}
		]
		}
		parent.emit_signal("start_dialog", answer)

func _on_PayTransportButton_pressed():
	pay_remaining($ExpensesContainer/TransportContainer/PayTransportButton, 
	$ExpensesContainer/TransportContainer/TransportValue,
	$ExpensesContainer/TransportContainer/PayTransportButtonPlus,
	$ExpensesContainer/TransportContainer/PayTransportButtonMinus)
	enable_certain_expense("Clothes")

func _on_PayClothesButton_pressed():
	pay_remaining($ExpensesContainer/ClothesContainer/PayClothesButton, 
	$ExpensesContainer/ClothesContainer/ClothesValue,
	$ExpensesContainer/ClothesContainer/PayClothesButtonPlus,
	$ExpensesContainer/ClothesContainer/PayClothesButtonMinus)
	enable_certain_expense("Freetime")

func _on_PayFreetimeButton_pressed():
	pay_remaining($ExpensesContainer/FreetimeContainer/PayFreetimeButton, 
	$ExpensesContainer/FreetimeContainer/FreetimeValue,
	$ExpensesContainer/FreetimeContainer/PayFreetimeButtonPlus,
	$ExpensesContainer/FreetimeContainer/PayFreetimeButtonMinus)
	parent.emit_signal("start_dialog")
	$Button.disabled = false


func _on_PayLoanButton_pressed():
	pass # Replace with function body.


func _on_PayFoodButtonPlus_pressed():
	add_to_expense("food", $ExpensesContainer/FoodContainer/FoodValue)

func _on_PayFoodButtonMinus_pressed():
	deduct_from_expense("food", $ExpensesContainer/FoodContainer/FoodValue)

func _on_PayTransportButtonPlus_pressed():
	add_to_expense("transport", $ExpensesContainer/TransportContainer/TransportValue)


func _on_PayTransportButtonMinus_pressed():
	deduct_from_expense("transport", $ExpensesContainer/TransportContainer/TransportValue)


func _on_PayClothesButtonPlus_pressed():
	add_to_expense("clothes", $ExpensesContainer/ClothesContainer/ClothesValue)


func _on_PayClothesButtonMinus_pressed():
	deduct_from_expense("clothes", $ExpensesContainer/ClothesContainer/ClothesValue)


func _on_PayFreetimeButtonPlus_pressed():
	add_to_expense("freetime", $ExpensesContainer/FreetimeContainer/FreetimeValue)


func _on_PayFreetimeButtonMinus_pressed():
	deduct_from_expense("freetime", $ExpensesContainer/FreetimeContainer/FreetimeValue)
