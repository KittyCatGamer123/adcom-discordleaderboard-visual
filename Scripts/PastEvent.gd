extends Node2D

var EVENT_ID = ""
var EVENT_NAME = ""
var START_DATE = ""
var END_DATE = ""

func _on_view_event_pressed():
	get_tree().root.get_node("Main").load_disboard(EVENT_ID, EVENT_NAME, START_DATE, END_DATE)
