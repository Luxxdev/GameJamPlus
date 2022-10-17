extends HBoxContainer

onready var playerNode = get_parent().get_parent().get_parent().get_node("Player")
var counter = 0

func _ready():
	playerNode.connect("healthChanged", self, "UpdateHealth")

func UpdateHealth(subtract : bool):
	if subtract:
		get_child(playerNode.health-1).visible = false
	else:
		counter += 1
		if counter == 3:
			counter = 0
			get_child(playerNode.health-1).visible = true
			playerNode.health += 1
