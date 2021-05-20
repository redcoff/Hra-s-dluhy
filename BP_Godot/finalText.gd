extends RichTextLabel


func _ready(): 
	connect("meta_clicked", self, "meta_clicked");
	
func meta_clicked(meta):
	print(meta)
	var command = 'window.location.replace(' + meta + ')'
	JavaScript.eval(command)
