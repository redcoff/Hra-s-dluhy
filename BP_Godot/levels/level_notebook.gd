extends Node2D

signal start_dialog

var LOAN_VALUE = 20000


var parent

var loan_type
var abg_try = false
var got_loan = false
var is_debt = false

func _ready():
	parent = get_parent()
	emit_signal("start_dialog")
	Sound.play_sound("keyboard")
	
	if Global.chapter == 10:
		$DebtLinkContainer.show()
		$LinkContainer.hide() 
		is_debt = true

func show_webpage(path):
	$BlurRect.show()
	$Button.show()
	$Loan.show()
	$PageContainer/PageRect.texture = load(path)
	$PageContainer.show()

func _on_BezPoplatkuALevneButton_pressed():
	loan_type = "Bez poplatku"
	$LinkContainer/BezPoplatkuALevneButton.release_focus()
	show_webpage("res://assets/GFX/Environment/WebPages/BezPoplatkuALevnePage.png")
	
func _on_NekrademeButton_pressed():
	$LinkContainer/NekrademeButton.release_focus()
	loan_type = "Nekrademe"
	show_webpage("res://assets/GFX/Environment/WebPages/Nekrademe.png")

func _on_AlfaBetaButton_pressed():
	$LinkContainer/AlfaBetaButton.release_focus()
	if !abg_try:
		loan_type = "Alfa Beta"
		show_webpage("res://assets/GFX/Environment/WebPages/Alfabeta.png")

	else:
		Global.target_check($LinkContainer/AlfaBetaButton)


func _on_Button_pressed():
	$BlurRect.hide()
	$Button.hide()
	$PageContainer.hide()
	$Loan.hide()


func _on_Loan_pressed():
	var answer
	$Loan.release_focus()
	if is_debt:
		answer = {
			"texts": 
			[
				{
					"char": "Marek",
					"emotion": "",
					"position": "left",
					"command": "",
					"say": ["Tak to zkusím asi tady..."],
				}
			]
		}
	else:
		if !abg_try:
			answer = {
			"texts": 
			[
				{
					"char": "Marek",
					"emotion": "",
					"position": "left",
					"command": "",
					"say": ["To vypadá dobře. Půjčím si tady 20 000 Kč."],
				}
			]
		}
		else:
			answer = {
			"texts": 
			[
				{
					"char": "Marek",
					"emotion": "",
					"position": "left",
					"command": "",
					"say": ["Tak snad tady to půjde."],
				}
			]
		}
	
	if loan_type == "Alfa Beta":
		start_call_branch_loan(answer)
	else:
		emit_signal("start_dialog", answer)
		got_loan = true
	
func start_call_branch_loan(answer):
	abg_try = true
	answer.texts.append({
		"char": "Telefon",
		"emotion": "",
		"position": "right",
		"command": "play_sound(ringtone)",
		"say": ["[i] *Zvoní telefon...* [/i]"],
	})
	answer.texts.append({
		"char": "Marek",
		"emotion": "",
		"position": "left",
		"command": "show_mobile(abg)",
		"say": ["Někdo mi volá....",
		"Marek Novotný, prosím?"],
	})
	answer.texts.append({
		"char": "ABG",
		"emotion": "",
		"position": "right",
		"command": "",
		"say": ["Dobrý den, pane Novotný. Dostali jsme Vaši žádost o půjčku. Podle registru jste ale nezaměsntaný, je to tak?"],
	})
	answer.texts.append({
		"char": "Marek",
		"emotion": "",
		"position": "left",
		"command": "",
		"say": ["Ano.. Ano, hledám si práci..."],
	})
	answer.texts.append({
		"char": "ABG",
		"emotion": "",
		"position": "right",
		"command": "",
		"say": ["V tomto případě Vám nemůžeme půjčku poskytnout. Je nám to moc líto."],
	})
	answer.texts.append({
		"char": "Marek",
		"emotion": "",
		"position": "left",
		"command": "",
		"say": ["Ale já potřebuju zaplatit nájem!"],
	})
	answer.texts.append({
		"char": "ABG",
		"emotion": "",
		"position": "right",
		"command": "",
		"say": ["Nemůžeme Vám nijak bohužel pomoct. Mějte se krásně, naslyšenou."],
	})
	answer.texts.append({
		"char": "Telefon",
		"emotion": "",
		"position": "left",
		"command": "play_sound(pipipip)",
		"say": ["[i]*Zavěšeno*[/i]"],
	})
	answer.texts.append({
		"char": "Marek",
		"emotion": "",
		"position": "left",
		"command": "hide_mobile",
		"say": ["To snad ne!", "Budu si muset půjčit jinde..."],
	})
	emit_signal("start_dialog", answer)
	
var additionalDialogDone = false
func _on_HUD_texts_finished():
	if got_loan:
		if loan_type != "Oddlužovací agentura":
			if is_debt: 
				if additionalDialogDone: 
					Global.target_check($Loan)
					parent.next_level()
				else: 
					emit_signal("start_dialog")
					additionalDialogDone = true
			else:
				Global.target_check($Loan)
				Global.revenues["loan"] += LOAN_VALUE
				Global.got_loan = true
				parent.next_level()
				return
		else:
			Global.player_data.end = "BAD_END"
			parent.start_fade("end")
	elif abg_try:
		_on_Button_pressed()


func _on_DebtAgency_pressed():
	$DebtLinkContainer/DebtAgencyButton.release_focus()
	loan_type = "Oddlužovací agentura"
	show_webpage("res://assets/GFX/Environment/WebPages/Rychlealevne.png")


func _on_NonProfitOrg_pressed():
	$DebtLinkContainer/NonProfitOrgButton.release_focus()
	loan_type = "Nezisková organizace"
	show_webpage("res://assets/GFX/Environment/WebPages/NadejeBezDluhu.png")
