extends Node2D

var ENDS = {
	'GOOD_END' : [
		"[center]Marek se díky dluhové poradně vydal na cestu oddlužení sebe a své rodiny.", 
		"[center]Dluhová poradna mu poskytovala podporu a pomohla Marka správně nasměrovat.",
		"[center]Bylo to pro Marka těžké, protože musel pracovat od rána do večera a striktně dodržovat pravidla.",
		"[center]Po několika letech Marek zaplatil poslední splátku.",
		"[center]A nyní je zcela bez dluhů.",
	],
	'BAD_END' : [
		"[center]Marek byl kontaktován oddlužovací agenturou.",
		"[center]Aby mu agentura poskytla pomoc, musel podepsat smlouvu, kde se zavázal o zaplacení až 15 000 Kč za oddlužení.",
		"[center]Mezitím si agentura účtovala další poplatky.",
		"[center]Po několika letech Marek a jeho rodina byla ještě ve větších dluzích.",
		"[center]Přišli o domov a neměli ani na jídlo...",
	]
}

var index = 0
var chosen_end

func _ready():
	chosen_end = Global.player_data.end
	if chosen_end == 'GOOD_END':
		$AudioStream.set_stream(Sound.music.good_end)
		$AudioStream.play()
	else:
		$AudioStream.set_stream(Sound.music.bad_end)
		$AudioStream.play()
	$FadeRectBackground/EndText.bbcode_text = ENDS[chosen_end][index]
	$FadeRectBackground/EndText/AnimationPlayer.play("TextShowing")

func _on_FadeRectBackground_animation_finished(anim_name):
	index += 1
	if ENDS[chosen_end].size() > index:
		$FadeRectBackground/EndText.bbcode_text = ENDS[chosen_end][index]
		$FadeRectBackground/EndText/AnimationPlayer.play("TextShowing")
	else:
		$FadeRectBackground/FinalText.show()
