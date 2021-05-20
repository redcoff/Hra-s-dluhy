extends Node2D

signal wallet_exit

var PART_CASH_MINUS = 500

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
var main_paied = false
var cached_button
var paied


func _ready():
	main_paied = false
	parent = get_parent()
	
	if Global.chapter > 2:
		init_settings()
		set_family_revenues()
		set_family_budget()
		$CashContainer/CashLabel.text = "Dohromady: "

	if Global.chapter > 4 and Global.got_loan:
		$ExpensesContainer/LoansContainer.show()
		$ExpensesContainer/LoansContainer/LoanContainer/LoanValue.text = str(number_format(Global.LOAN_PAYMENT)) + suffix
		
	update_total_cash()
	set_wallet_pic()

func init_settings():
	$FinanceContainer/RevenuesContainer.show()
	$ExpensesContainer.show()
	$Button.disabled = true
		
	Global.revenues["marek"] = 0

func set_loan_payment():
	Global.revenues["marek"] = 17000
	Global.current_cash += Global.revenues["marek"]
	parent.emit_signal("start_dialog")
	$Button.disabled = true
	$ExpensesContainer/LoansContainer/LoanContainer/PayLoanButton.show()
	$FinanceContainer/RevenuesContainer/MarekContainer/MarekValue.text = str(number_format(Global.revenues["marek"])) + suffix
	$ExpensesContainer/LoansContainer/LoanContainer/LoanValue.text = str(number_format(Global.expenses["loan"])) + suffix
	update_total_cash()

func update_revs():
	Global.current_cash += Global.revenues["loan"]
	$FinanceContainer/RevenuesContainer/PlusLoanContainer.show()
	$FinanceContainer/RevenuesContainer/PlusLoanContainer/PlusLoanValue.text = str(number_format(Global.revenues["loan"])) + suffix
	update_total_cash()
	$Button.disabled = true
	cached_button.disabled = false
	Global.revenues["loan"] = 0

func update_total_cash():
	if Global.current_cash < 0:
		Global.current_cash = 0
	set_wallet_pic()
	$CashContainer/CashValueLabel.text = str(number_format(Global.current_cash))

func set_wallet_pic():
	if Global.current_cash >= 4500:
		$Background/WalletTexture.texture = load("res://assets/GFX/Environment/Wallet/wallet_full.png")
	elif Global.current_cash >= 500:
		$Background/WalletTexture.texture = load("res://assets/GFX/Environment/Wallet/wallet_half.png")
	else:
		$Background/WalletTexture.texture = load("res://assets/GFX/Environment/Wallet/wallet_empty.png")
		
func set_family_revenues():
	if Global.current_cash > 0:
		Global.revenues["save"] = Global.current_cash
		Global.current_cash = 0
	$FinanceContainer/RevenuesContainer/MarekContainer/MarekValue.text = str(number_format(Global.revenues["marek"])) + suffix
	$FinanceContainer/RevenuesContainer/PetraContainer/PetraValue.text = str(number_format(Global.revenues["petra"])) + suffix
	$FinanceContainer/RevenuesContainer/SaveContainer/SaveValue.text = str(number_format(Global.revenues["save"])) + suffix
	for rev in Global.revenues:
		Global.current_cash += Global.revenues[rev]
	Global.revenues["save"] = 0

func set_family_budget():
	$ExpensesContainer.show()
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
	if Global.chapter >= 3: 
			Global.target_check("Paied")
	if (Global.chapter == 4 and !Global.got_loan) or Global.chapter == 5:
		parent.remove_child(self)
	else:
		queue_free()
	emit_signal("wallet_exit")

func pay_expense(node_button, exp_name, node_label):
	node_button.release_focus()
	if Global.current_cash >= Global.expenses[exp_name]:
		paied = exp_name
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
		cached_button = node_button
		
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
		if Global.chapter == 3 or Global.chapter > 4:
			if Global.chapter == 3 or Global.chapter == 5: 
				parent.emit_signal("start_dialog")
			reset_remaining_expenses()
			enable_certain_expense("Food")
		elif Global.chapter == 4 and Global.got_loan:
			parent.emit_signal("start_dialog")
			show_certain_only_pay()
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
	set_after_main_paied()
			
func _on_PayEnergyButton_pressed():
	pay_expense($ExpensesContainer/EnergyContainer/PayEnergyButton, 
	"energy",
	$ExpensesContainer/EnergyContainer/EnergyValue)
	set_after_main_paied()
			
func pay_remaining(node_button, node_label, node_plus, node_minus):
	node_button.release_focus()
	node_label.set("custom_colors/font_color",Color8(255,204,102))
	node_button.hide()
	node_plus.hide()
	node_minus.hide()
	
func _on_PayFoodButton_pressed():
	if Global.chapter == 4 and Global.got_loan:
		pay_expense($ExpensesContainer/FoodContainer/PayFoodButton, 
		"energy",
		$ExpensesContainer/FoodContainer/FoodValue)
	elif actual_budget["food"] > 2000:
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
	if Global.chapter == 4 and Global.got_loan:
		pay_expense($ExpensesContainer/TransportContainer/PayTransportButton, 
		"energy",
		$ExpensesContainer/TransportContainer/TransportValue)
	else:
		pay_remaining($ExpensesContainer/TransportContainer/PayTransportButton, 
		$ExpensesContainer/TransportContainer/TransportValue,
		$ExpensesContainer/TransportContainer/PayTransportButtonPlus,
		$ExpensesContainer/TransportContainer/PayTransportButtonMinus)
		enable_certain_expense("Clothes")

func _on_PayClothesButton_pressed():
	if Global.chapter == 4 and Global.got_loan:
		pay_expense($ExpensesContainer/ClothesContainer/PayClothesButton, 
		"energy",
		$ExpensesContainer/ClothesContainer/ClothesValue)
	else:
		pay_remaining($ExpensesContainer/ClothesContainer/PayClothesButton, 
		$ExpensesContainer/ClothesContainer/ClothesValue,
		$ExpensesContainer/ClothesContainer/PayClothesButtonPlus,
		$ExpensesContainer/ClothesContainer/PayClothesButtonMinus)
		enable_certain_expense("Freetime")

func _on_PayFreetimeButton_pressed():
	if Global.chapter == 4 and Global.got_loan:
		pay_expense($ExpensesContainer/FreetimeContainer/PayFreetimeButton, 
		"energy",
		$ExpensesContainer/FreetimeContainer/FreetimeValue)
	else:
		pay_remaining($ExpensesContainer/FreetimeContainer/PayFreetimeButton, 
		$ExpensesContainer/FreetimeContainer/FreetimeValue,
		$ExpensesContainer/FreetimeContainer/PayFreetimeButtonPlus,
		$ExpensesContainer/FreetimeContainer/PayFreetimeButtonMinus)
		if Global.chapter != 7: 
			parent.emit_signal("start_dialog")
	$Button.disabled = false

func show_certain_only_pay():
	$ExpensesContainer/FoodContainer/PayFoodButton.show()
	$ExpensesContainer/TransportContainer/PayTransportButton.show()
	$ExpensesContainer/ClothesContainer/PayClothesButton.show()
	$ExpensesContainer/FreetimeContainer/PayFreetimeButton.show()

func _on_PayLoanButton_pressed():
	pay_expense($ExpensesContainer/LoansContainer/LoanContainer/PayLoanButton,
	 "loan", 
	$ExpensesContainer/LoansContainer/LoanContainer/LoanValue)
	$Button.disabled = false

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
