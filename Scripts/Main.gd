extends Node2D

@onready var PositionsList: Marker2D = get_node("positions")
@onready var MaxScroll = 0
var backupPlayfabPool = [
	"1A8E38C3AA38A635",
	"E1E1B9F3C494F075",
	"9C5D3DB5B7C26E65",
	"CE28EC0D8F47E956",
	"A877F6523108F4F8"
]

var activePlayfab = "2009767D308F4315"
var activeRequest = false
var latestEventId = null

# :ech:
# Unix times in Irish Time
var aprilFools2024_start = 1711926000
var aprilFools2024_end = 1712012400

func _ready():
	get_node("overlay").visible = false
	$httpGetPlayfab.connect("request_completed",Callable(self,"_on_httpGetPlayfab_request_completed"))
	$httpGetPlayfab.request("https://darrenskidmore.com/adcom-leaderboard/api/list/" + activePlayfab)
	activeRequest = true

func _on_httpGetPlayfab_request_completed(_result, _response_code, _headers, body):
	activeRequest = false
	var test_json_conv = JSON.new()
	test_json_conv.parse(body.get_string_from_utf8())
	var json = test_json_conv.get_data()
	if json != null:
		latestEventId = json[0].eventId
		if load("res://Assets/Events/" + json[0].eventName + ".png") == null:
			$overlay/ToggleNewsModal.position = Vector2(-541, -1200)
			$overlay/Top100Button.position = Vector2(144, -1197)
			$overlay/ConnectButton.visible = false
		get_node("overlay").texture = load("res://Assets/Events/" + json[0].eventName + ".png")
		get_node("overlay").visible = true
		$httpGetEvent.connect("request_completed",Callable(self,"_on_httpGetEvent_request_completed"))
		$httpGetEvent.request("https://darrenskidmore.com/adcom-leaderboard/api/discord/" + latestEventId)
		activeRequest = true
		initaliseSpecialNotifications(latestEventId)
		$overlay/ModeDisplay.text = "Discordboard"
	else:
		$background/LoadingData.text = "[indent][center]Error retrieving data!"

func _on_disboard_button_pressed():
	if not activeRequest:
		$overlay/ModeDisplay.text = "Discordboard"
		$httpGetPlayfab.connect("request_completed",Callable(self,"_on_httpGetPlayfab_request_completed"))
		$httpGetPlayfab.request("https://darrenskidmore.com/adcom-leaderboard/api/list/2009767D308F4315")
		MaxScroll = 0
		activeRequest = true
		for i in $positions.get_children(): i.queue_free()

func _on_top_100_button_pressed():
	if not activeRequest:
		# If I don't start an event, the T100 won't load
		# So I need to pick an ID that is always playing every single event.
		var playfab = backupPlayfabPool[randi() % backupPlayfabPool.size()]
		
		$overlay/ModeDisplay.text = "Top 100"
		$httpGetTop100.connect("request_completed", Callable(self, "_on_http_get_top_100_request_completed"))
		$httpGetTop100.request("https://darrenskidmore.com/adcom-leaderboard/api/event/{id}/{playfab}/top/100".replace("{id}", latestEventId).replace("{playfab}", playfab))
		activeRequest = true
		for i in $positions.get_children(): i.queue_free()

func _on_httpGetEvent_request_completed(_result, _response_code, _headers, body):
	activeRequest = false
	for n in PositionsList.get_children():
		PositionsList.remove_child(n)
		n.queue_free()
	
	var positionNode = load("res://Scenes/Position.tscn")
	var test_json_conv = JSON.new()
	test_json_conv.parse(body.get_string_from_utf8())
	var json = test_json_conv.get_data()
	var leaderboard = json
	var y = (1201 * 0.75) + 39
	
	for i in range(0, len(leaderboard)):
		var index = leaderboard[i]
		var name = index.name.replace("♡", "").replace("♛", "")
		var trophies = index.trophies
		
		# Instanciate the Position scene
		var newPosition = positionNode.instantiate()
		PositionsList.add_child(newPosition)
		newPosition.position = Vector2(409, y)
		
		# Trims player name if it's too long
		name = General.usernameSize(name)
		
		# Player Icon (Easter Echggs go here)
		if str(index["discordId"]) == "169657387844632576" and i == 0:
			newPosition.PlayerIcon.texture = load("res://Assets/PlayerIcons/EasterEggs/JerryFirst.png")
		elif str(index["discordId"]) == "603952274670223401" and index.position <= 25:
			newPosition.PlayerIcon.texture = load("res://Assets/PlayerIcons/EasterEggs/PuppyTop25.png")
		else:
			newPosition.PlayerIcon.texture = General.playerIconByDiscordId(index["discordId"])
		
		# Global Position & Reward
		var globalPosition = index.position
		var positionSuffix = General.positionNumberFormat(globalPosition, 45)
		
		if int(globalPosition) == 1: newPosition.PositionReward.texture = load("res://Assets/Capsules/icon-champion-medium.png")
		elif int(globalPosition) in range(2, 6): newPosition.PositionReward.texture = load("res://Assets/Capsules/icon-top5-medium.png")
		elif int(globalPosition) in range(6, 26): newPosition.PositionReward.texture = load("res://Assets/Capsules/icon-top25-medium.png")
		elif int(globalPosition) in range(26, 101): newPosition.PositionReward.texture = load("res://Assets/Capsules/icon-top100-medium.png")
		else: 
			var playersOnBoard = leaderboard[0]["positionOf"]
			var globalPercent = floor((index.position / playersOnBoard) * 100)
			if globalPercent <= 1: newPosition.PositionPercent.text = "Top\n1%"
			elif int(globalPercent) in range(1, 6): newPosition.PositionPercent.text = "Top\n5%"
			elif int(globalPercent) in range(6, 11): newPosition.PositionPercent.text = "Top\n10%"
			elif int(globalPercent) in range(11, 26): newPosition.PositionPercent.text = "Top\n25%"
			elif int(globalPercent) in range(26, 51): newPosition.PositionPercent.text = "Top\n50%"
			elif int(globalPercent) in range(51, 76): newPosition.PositionPercent.text = "Top\n75%"
			elif int(globalPercent) in range(76, 101): newPosition.PositionPercent.text = "Top\n100%"
		
		# Set variables
		newPosition.Username = name
		newPosition.PositionNumber = i + 1
		newPosition.Trophies = trophies
		newPosition.GlobalText = "[indent]" + str(globalPosition) + positionSuffix
		newPosition.PlayerData = index
		
		# Position Number background colour
		match i:
			0: newPosition.PositionColour.texture = load("res://Assets/UI/PositionColours/position_first.png")
			1: newPosition.PositionColour.texture = load("res://Assets/UI/PositionColours/position_second.png")
			2: newPosition.PositionColour.texture = load("res://Assets/UI/PositionColours/position_third.png")
			_: newPosition.PositionColour.texture = load("res://Assets/UI/PositionColours/position_other.png")
		
		# April Fools reverse names :ech:
		if Time.get_unix_time_from_system() >= aprilFools2024_start && Time.get_unix_time_from_system() <= aprilFools2024_end:
			var aprilFoolsNamesplit = newPosition.Username.split("")
			aprilFoolsNamesplit.reverse()
			newPosition.Username = "".join(aprilFoolsNamesplit)
		
		y += (171 * 0.75)
		MaxScroll -= (171 * 0.75)
	
	$positions.position.y = 0
	if len(leaderboard) >= 6: $positions.maxScroll = MaxScroll + 625
	else: $positions.maxScroll = 0

func _on_http_get_top_100_request_completed(result, response_code, headers, body):
	activeRequest = false
	var test_json_conv = JSON.new()
	test_json_conv.parse(body.get_string_from_utf8())
	
	var top100 = test_json_conv.get_data()["top"]["list"]
	var positionNode = load("res://Scenes/PositionTop100.tscn")
	var y = (1201 * 0.75) + 39
	var iconColours = { 
		"Red": Color("f2002f"),
		"Orange": Color("ff5118"),
		"Yellow": Color("e19e45"),
		"Green": Color("00c597"),
		"Blue": Color("5fa1fd"),
		"Pink": Color("f26eb9"),
	}
	
	# just for fun c:
	# nick dont kill me pls it's just a joke--
	var hackerNamesOverride = [ "supreme cringe c", "godly loser x", "secret agent stupid v", "tiny brain i", "HH Nick", "cringe hacker x", "sus player c", "omega weirdo l", "true comrade l" ]
	
	for i in range(0, len(top100)):
		var index = top100[i]
		var playerDisplayMetadata = get_ingame_username_icon(index["ordinal"])
		var newPosition = positionNode.instantiate()
		PositionsList.add_child(newPosition)
		newPosition.position = Vector2(409, y)
		
		# Hacker alert (boooo!)
		if index["trophies"] >= 1000000:
			newPosition.get_node("Box/Username").self_modulate = Color("a30023")
			newPosition.get_node("Box/Username").text = hackerNamesOverride[randi() % hackerNamesOverride.size()]
		else:
			newPosition.get_node("Box/Username").self_modulate = Color("ffffff")
			newPosition.get_node("Box/Username").text = playerDisplayMetadata[0]
		
		newPosition.get_node("Box/Icon").texture = load("res://Assets/GlobalIcons/Icon-{i}.png".replace("{i}", playerDisplayMetadata[2]))
		newPosition.get_node("Box/Icon").self_modulate = iconColours[playerDisplayMetadata[1]]
		newPosition.get_node("Box/PositionNo").text = str(i + 1)
		newPosition.get_node("Box/TrophyCount").text = General.addCommas(index["trophies"])
		
		match i:
			0: newPosition.get_node("Box/PositionNumColour").texture = load("res://Assets/UI/PositionColours/position_first.png")
			1: newPosition.get_node("Box/PositionNumColour").texture = load("res://Assets/UI/PositionColours/position_second.png")
			2: newPosition.get_node("Box/PositionNumColour").texture = load("res://Assets/UI/PositionColours/position_third.png")
			_: newPosition.get_node("Box/PositionNumColour").texture = load("res://Assets/UI/PositionColours/position_other.png")
			
		if i == 0: newPosition.get_node("Box/PositionReward").texture = load("res://Assets/Capsules/icon-champion-medium.png")
		elif i in range(1, 5): newPosition.get_node("Box/PositionReward").texture = load("res://Assets/Capsules/icon-top5-medium.png")
		elif i in range(5, 25): newPosition.get_node("Box/PositionReward").texture = load("res://Assets/Capsules/icon-top25-medium.png")
		else: newPosition.get_node("Box/PositionReward").texture = load("res://Assets/Capsules/icon-top100-medium.png")
		
		y += (171 * 0.75)
	
	$positions.position.y = 0
	$positions.maxScroll = -12197

# Thanks for letting me steal this code Enigma LOL
func get_ingame_username_icon(n):
	var odict = {
		"Adjectives": ["Supreme", "Super", "Glorious", "Marvelous", "Brilliant", "Great", "Prosperous", "Red", "Pink", "Crimson", "Scarlet", "Patriotic", "True", "Model", "Communistic", "Iron"],
		"Nouns": ["Chicken", "Captain", "Communist", "Comrade", "Leader", "Guardian", "Guard", "Worker", "Pioneer", "Soldier", "Proletariat", "Revolutionist", "Socialist"],
		"Generations": ["I", "V", "X", "L", "C", "D", "M"],
		"IconColors": ["Green", "Blue", "Pink", "Red", "Orange", "Yellow"],
		"IconTextures": ["Bomb", "Boot", "Cactus", "Dino", "Chicken", "Fish", "Skull", "Sword"]
	}
	var baseCaseIndex = [0, 7, 4, 0, 0]
	var incrementValue = [1, 2, 3, 1, 1]
	
	var n0 = odict["Adjectives"][int((n * incrementValue[0]) + baseCaseIndex[0]) % odict["Adjectives"].size()]
	var n1 = odict["Nouns"][int((n * incrementValue[1]) + baseCaseIndex[1]) % odict["Nouns"].size()]
	var n2 = odict["Generations"][int((n * incrementValue[2]) + baseCaseIndex[2]) % odict["Generations"].size()]
	var ic = odict["IconColors"][int((n * incrementValue[3]) + baseCaseIndex[3]) % odict["IconColors"].size()]
	var ip = odict["IconTextures"][int((n * incrementValue[4]) + baseCaseIndex[4]) % odict["IconTextures"].size()]
	return [ n0 + " " + n1 + " " + n2, ic, ip ]

func _on_enigma_credit_pressed():
	OS.shell_open("https://darrenskidmore.com/adcom-leaderboard/discord")

func _on_form_link_pressed():
	OS.shell_open("https://darrenskidmore.com/adcom-leaderboard/account")

func _on_open_source_pressed():
	OS.shell_open("https://github.com/KittyCatGamer123/adcom-discordleaderboard-visual")

# I'll have to update this manually in accordance to whatever Enigma puts in for stuff
func initaliseSpecialNotifications(eventId):
	const warnings = {
		"922fc5f1-aafc-4e73-bd08-8ce2cd2ae2c9": "During the runtime of this event, there was a known exploit which compromised the integrity of the leaderboards. Results may not be accurate."
	}
	
	if warnings.get(eventId) != null:
		$SpecialNotice.text = "NOTE: " + warnings.get(eventId)
