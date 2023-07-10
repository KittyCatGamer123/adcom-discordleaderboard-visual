extends Marker2D

@onready var scrollSpeed = 50
@onready var maxScroll = 0
@onready var mouseDragging = false
@onready var scrollMinimum = 1.7

# Called when the node enters the scene tree for the first time.
func _ready():
	$"../popupPosition".position.y = 0
	position.y = 0

func _process(delta):
	if General.modal_open == false:
		if Input.is_action_just_released("mou_scrollup"):
			position.y += scrollSpeed
			$"../popupPosition".position.y += scrollSpeed
			if position.y > 0: position.y = 0; $"../popupPosition".position.y = 0
			snapY()
			killPlayerModal()
		
		elif Input.is_action_just_released("mou_scrolldown"):
			position.y -= scrollSpeed
			$"../popupPosition".position.y -= scrollSpeed
			snapY()
			killPlayerModal()

func _input(event):
	# Drag-scrolling
	if General.modal_open == false:
		if event is InputEventMouseMotion:
			var relativeY = event.relative.y
			var canDrag = false
			if relativeY < 0: canDrag = (relativeY <= -scrollMinimum)
			elif relativeY > 0: canDrag = (relativeY >= scrollMinimum)
			
			if General.mouse_pressed and canDrag:
				mouseDragging = true
				position.y += event.relative.y
				$"../popupPosition".position.y += event.relative.y
				killPlayerModal()
				snapY()
			else: mouseDragging = false

func killPlayerModal():
	var statsModalExists = get_tree().get_root().get_node("Main").get_node_or_null("popupPosition/PlayerStatsModal")
	if statsModalExists: statsModalExists.queue_free()

func snapY():
	if position.y > 0: position.y = 0; $"../popupPosition".position.y = 0
	if position.y < maxScroll: position.y = maxScroll; $"../popupPosition".position.y = maxScroll
