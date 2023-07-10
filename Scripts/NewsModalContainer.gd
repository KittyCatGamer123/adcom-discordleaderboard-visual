extends ColorRect

const UPDATE_HISTORY = [
	{
		"Version": "1.4.0",
		"Contents": [
			"You can return back to the Discordboard after loading the Top 100 now by pressing the Leaderboard icon.",
			"There's now text displaying what mode you are in, such as '[color=yellow]Discordboard[/color]' or '[color=yellow]Top 100[/color]'.",
			"Added commas to [color=lime]trophy[/color] counts, along with the icon being moved to the right of the number instead."
		]
	},
	{
		"Version": "1.3.0",
		"Contents": [
			"[color=yellow]Top 100[/color] leaderboard is now an option by hitting the Global icon!",
			"The site's [color=yellow]source code[/color] is now available on [color=lime]GitHub[/color]! See the \"View Source\" for details."
		]
	},
	{
		"Version": "1.2.1",
		"Contents": [
			"Added two small easter eggs.",
			"Minor alignment tweaks to player modal."
		]
	},
	{
		"Version": "1.2.0",
		"Contents": [
			"[color=yellow]Usernames[/color] should now be clickable for mobile -- added deadzone for scrolling. [color=gray](May make shorter scrolling more difficult though)[/color].",
			'Added [color=lime]"API by Enigma"[/color] (sends to original leaderboard page) and [color=lime]"Join Discord Board"[/color] (sends to form to join the board) buttons.',
			"[s][color=gray]Replaced[/color][/s] Fixed missing bullet-point icon in News menu, along with extra colouring in general to changelogs."
		]
	},
	{
		"Version": "1.1.0",
		"Contents": [
			"[color=lime]Dragging to scroll[/color] now works for those who do not have a mouse wheel or are on mobile.",
			"Created the \"[color=yellow]News[/color]\" menu.",
			"Overflow at the end of player positions reduced. [color=gray](hopefully)[/color]"
		]
	},
	{
		"Version": "1.0.0",
		"Contents": [
			"Initial release of the visual leaderboard!"
		]
	}
]

var update_index = 0

func _on_toggle_news_modal_pressed():
	update_index = 0
	beautify_data()
	General.modal_open = true
	visible = true

func _on_close_model_pressed():
	General.modal_open = false
	visible = false

func beautify_data():
	if update_index == 0: $WoodPanel/BoltedBar/SelectNewer.disabled = true
	else: $WoodPanel/BoltedBar/SelectNewer.disabled = false
	
	if update_index == (len(UPDATE_HISTORY) - 1): $WoodPanel/BoltedBar/SelectOlder.disabled = true
	else: $WoodPanel/BoltedBar/SelectOlder.disabled = false
	
	var version = UPDATE_HISTORY[update_index]
	$WoodPanel/BoltedBar/VersionNo.text = version["Version"]
	
	var text = "[font_size=45][b]Version v" + version["Version"] + "[/b][/font_size]\n"
	for bp in version["Contents"]: text += "- " + bp + "\n"
	$WoodPanel/ContentPanel/VersionContent.text = text

func _on_select_older_pressed():
	update_index += 1
	beautify_data()

func _on_select_newer_pressed():
	update_index -= 1
	beautify_data()
