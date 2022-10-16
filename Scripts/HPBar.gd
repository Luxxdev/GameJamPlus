extends ProgressBar

onready var playerNode = get_parent().get_parent().get_node("Player")

func _ready():
	playerNode.connect("healthChanged", self, "UpdateHealth")

func UpdateHealth():
	value = playerNode.health
