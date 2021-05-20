extends Node2D

signal character_image_changed
signal character_second_image_changed

var OWN_OFFSET = {
	"Petra": 0,
	"Káťa": 0,
	"Šimon": 150,
	"Marie": 0
}

func _ready():
	visible = false

func _on_DialogBox_character_changed(name, emotion):
	var offset = 0
	var loaded = load_character(name, emotion)
	if name in OWN_OFFSET: offset = OWN_OFFSET[name]
	if loaded: emit_signal("character_image_changed", $char_sprite.texture.get_size(), offset)

func _on_DialogBox_all_texts_finished():
	visible = false

func load_character(name, emotion):
	if emotion != "" and name != "..." and name != "Barman":
		var texture_dict = "res://assets/GFX/Characters/" + name + "/"
		print(texture_dict)
		var image = load(texture_dict + name + "_" + emotion + '.png')
		$char_sprite.set_texture(image)
		visible = true
		return true
	return false

func _on_DialogBox_character_second_changed(name, emotion):
	var offset = 0
	var loaded = load_character(name, emotion)
	if name in OWN_OFFSET: offset = OWN_OFFSET[name]
	if loaded: emit_signal("character_second_image_changed", $char_sprite.texture.get_size(), offset)

func _on_DialogBox_character_third_changed(name, emotion):
	load_character(name, emotion)
