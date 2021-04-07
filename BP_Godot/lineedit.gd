extends LineEdit

var regex = RegEx.new()
var oldtext = ""

func _ready():
	regex.compile("^[0-9]*$")

func check_text(new_text):
	if regex.search(new_text):
		text = new_text   
		oldtext = text
	else:
		text = oldtext
	set_cursor_position(text.length())

func get_value():
	return(int(text))


func _on_RentValue_text_changed(new_text):
	check_text(new_text)
