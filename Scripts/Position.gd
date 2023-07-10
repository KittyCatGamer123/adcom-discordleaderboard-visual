extends Node2D

@export var Username: String = "Username"
@export var PositionNumber: int = 1
@export var Trophies: int = 999999

@onready var UserName = get_node("Box/TogglePlayerModal")
@onready var PosNum: Label = get_node("Box/PositionNo")
@onready var TrophyCount: Label = get_node("Box/TrophyCount")
@onready var PositionColour: Sprite2D = get_node("Box/PositionNumColour")
@onready var PlayerIcon: Sprite2D = get_node("Box/Icon")
@onready var GlobalPosition: RichTextLabel = get_node("Box/GlobalPosition")
@onready var PositionReward: TextureRect = get_node("Box/PositionReward")
@onready var PositionPercent: Label = get_node("Box/PositionReward/PositionPercent")
@onready var GlobalText: String = "--th"
@onready var PlayerData = {}
#onready var LastLogin: Label = get_node("Box/LastETA")

var playerInfo = preload("res://Scenes/PlayerStatsModal.tscn")

func _ready():
	UserName.text = Username
	PosNum.text = str(PositionNumber)
	TrophyCount.text = str(Trophies)

func _process(delta):
	UserName.text = Username
	PosNum.text = str(PositionNumber)
	TrophyCount.text = General.addCommas(Trophies)
	GlobalPosition.text = GlobalText

func _on_toggle_player_modal_pressed():
	var mainScene = get_tree().get_root().get_node("Main")
	if not mainScene.get_node("positions").mouseDragging && General.modal_open == false:
		var statsModalExists = mainScene.get_node_or_null("popupPosition/PlayerStatsModal")
		if statsModalExists: 
			statsModalExists.queue_free()
		if statsModalExists == null:
			var plr = playerInfo.instantiate()
			mainScene.get_node("popupPosition").add_child(plr)
			var globalPercent = snapped((PlayerData["position"] / PlayerData["positionOf"]) * 100, 0.01)
			plr.position = self.position
			plr.Username.text = PlayerData["name"].replace("♡", "").replace("♛", "")
			plr.Icon.texture = General.playerIconByDiscordId(PlayerData["discordId"])
			plr.DiscordTag.text = PlayerData["discordName"]
			plr.TrophiesCount.text = "[center]\n[font_size=20]Trophies\n[font_size=50]" + str(PlayerData["trophies"])
			plr.DivisionCount.text = "[center]\n[font_size=20]Division Position\n[font_size=50]" + str(PlayerData["divisionPosition"]) + General.positionNumberFormat(PlayerData["divisionPosition"], 40, true)
			plr.GlobalCount.text = "[center]\n[font_size=20]Global Position\n[font_size=50]" + str(PlayerData["position"]) + General.positionNumberFormat(PlayerData["position"], 40, true)
			plr.LastUpdate.text = "Last Updated: " + PlayerData["lastUpdated"].replace("T", " ").split(".")[0]
			
			if (PlayerData["discordId"] == "460561415619739670") or (PlayerData["discordId"] == "530418942456496138"):
				plr.DevBadge.visible = true

	#contents += "Division Position: " + str(data["divisionPosition"]) + General.positionNumberFormat(data["divisionPosition"], 1, false) + "\n"
