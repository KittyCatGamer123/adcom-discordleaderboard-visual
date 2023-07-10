extends TextureButton

@onready var displayBubble = get_node("CanvasGroup")

func _ready():
	displayBubble.visible = false

func _on_toggled(button_pressed):
	displayBubble.visible = button_pressed
