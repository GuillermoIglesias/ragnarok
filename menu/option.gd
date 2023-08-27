extends ColorRect

signal selected_upgrade(upgrade)

@onready var title = $Title
@onready var description = $Description
@onready var level = $Level
@onready var icon = $Picture/Icon

var mouse_over = false
var item = null

@onready var player = get_tree().get_first_node_in_group("player")


func _ready():
	connect("selected_upgrade", Callable(player, "set_upgrade"))
#	player.selected_upgrade.connect(set_upgrade)
#	if item == null:
#		item = "food"
#	lblName.text = UpgradeDb.UPGRADES[item]["displayname"]
#	lblDescription.text = UpgradeDb.UPGRADES[item]["details"]
#	lblLevel.text = UpgradeDb.UPGRADES[item]["level"]
#	itemIcon.texture = load(UpgradeDb.UPGRADES[item]["icon"])


func _process(_delta):
	if Input.is_action_just_pressed("left_click"):
		if mouse_over:
			selected_upgrade.emit(item)


func _on_mouse_entered():
	mouse_over = true


func _on_mouse_exited():
	mouse_over = false
