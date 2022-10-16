extends VBoxContainer

onready var bossNode = get_parent().get_parent().get_parent().get_parent().get_node("Boss")

func _ready():
	bossNode.connect("healthChanged", self, "UpdateHealth")
	

func UpdateHealth():
	$HBoxContainer.value = bossNode.life


func _on_Boss_visibility_changed():
	visible = !visible
