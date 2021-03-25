extends Node2D


func _ready():
	$char_sprite.visible = false



func _on_DialogBox_character_changed(name, emotion):
	var texture_dict = 'assets/GFX/Characters/' + name + "/"
	var image = load(texture_dict + name + "_" + emotion + '.png')
	
	print(texture_dict + name + "_" + emotion + '.png')
	print(image)
	#image.load(texture_dict + name + '.jpg')
	$char_sprite.set_texture(image)
	$char_sprite.visible = true


func _on_DialogBox_all_texts_finished():
	$char_sprite.visible = false
