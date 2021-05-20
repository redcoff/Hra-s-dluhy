extends Node2D

signal decision_picked

func _ready():
	get_parent().hide_micromenu()

func set_decisions(context):
	if context == "go_or_throw_away":
		$BlurRect/LeftDecision.text = "Zahodit dopis"
		$BlurRect/RightDecision.text = "Jít za věřitelem"
	if context == "objection_or_silence":
		$BlurRect/LeftDecision.text = "Nic neříkat"
		$BlurRect/RightDecision.text = "Namítnout"

func _on_LeftDecision_pressed():
	emit_signal("decision_picked", "pass")
	queue_free()


func _on_RightDecision_pressed():
	emit_signal("decision_picked", "go")
	queue_free()
