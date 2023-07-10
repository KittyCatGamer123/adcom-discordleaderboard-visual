extends Node

@onready var mouse_pressed = false
@onready var modal_open = false

func _input(event):
	if event is InputEventMouseButton: mouse_pressed = event.pressed

func usernameSize(n):
	if n.length() >= 20:
			n = n.substr(0, 18)
			n += "..."
	return n

func addCommas(n):
	var result := ""
	var i: int = abs(n)
	
	while i > 999:
		result = ",%03d%s" % [i % 1000, result]
		i /= 1000
	
	return "%s%s%s" % ["-" if n < 0 else "", i, result]

func playerIconByDiscordId(discordId):
	var pathObjective = load("res://Assets/PlayerIcons/" + discordId + ".png")
	if pathObjective:
		return pathObjective
	else:
		return load("res://Assets/PlayerIcons/_default.png")

func positionNumberFormat(number, text_size, bbcode = true):
	number = str(number)
	if number.right(1) == "1" and number != "11":
		if bbcode: return "[font_size=" + str(text_size) + "]st[/font_size]"
		else: return "st"
	elif number.right(1) == "2" and number != "12":
		if bbcode: return "[font_size=" + str(text_size) + "]nd[/font_size]"
		else: return "nd"
	elif number.right(1) == "3" and number != "13":
		if bbcode: return "[font_size=" + str(text_size) + "]rd[/font_size]"
		else: return "rd"
	else:
		if bbcode: return "[font_size=" + str(text_size) + "]th[/font_size]"
		else: return "th"
