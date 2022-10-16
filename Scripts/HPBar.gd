extends VSlider

onready var playerNode = get_parent().get_parent().get_node("Player")

# Called when the node enters the scene tree for the first time.
func _ready():
	playerNode.connect("healthChanged", self, "UpdateHealth")

func UpdateHealth():
	value = playerNode.health
