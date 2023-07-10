extends TextureButton

func _ready():
	$Describe.visible = false

func _on_mouse_entered():
	$Describe.visible = true

func _on_mouse_exited():
	$Describe.visible = false
