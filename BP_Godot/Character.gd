extends Node2D

signal character_image_changed
signal character_second_image_changed

func _ready():
	visible = false



func _on_DialogBox_character_changed(name, emotion):
	var loaded = load_character(name, emotion)
	if loaded: emit_signal("character_image_changed", $char_sprite.texture.get_size())


func _on_DialogBox_all_texts_finished():
	visible = false

func load_character(name, emotion):
	if emotion != "" and name != "..." and name != "Barman":
		var texture_dict = 'assets/GFX/Characters/' + name + "/"
		var image = load(texture_dict + name + "_" + emotion + '.png')
		$char_sprite.set_texture(image)
		visible = true
		return true
	return false

func _on_DialogBox_character_second_changed(name, emotion):
	var loaded = load_character(name, emotion)
	if loaded: emit_signal("character_second_image_changed", $char_sprite.texture.get_size())
