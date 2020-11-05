extends KinematicBody

onready var nav_parent : Navigation = get_parent()
var path: PoolVector3Array # path in terms of Vector 3 points to travel along
var path_idx = 0
const move_speed = 12
const move_precision = 1.8 # the distance at which the target will stop moving closer if crossed



# Team Properties
export (Globals.TEAMS) var team = Globals.TEAMS.PLAYER
var team_colors = {
	Globals.TEAMS.PLAYER: preload("res://Assets/TeamZeroMaterial.tres"),
	Globals.TEAMS.ENEMY: preload("res://Assets/TeamOneMaterial.tres")
}




# Called when the node enters the scene tree for the first time.
func _ready():
	$MeshInstance.material_override = team_colors[team]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	#move along path
	if path_idx < path.size():
		var move_vec: Vector3 = (path[path_idx] - global_transform.origin)
		print("moving", move_vec.length())
		if move_vec.length() < move_precision:
			print("move_vec.length() stopped with len of ", move_vec.length())
			path_idx += 1
		else:
			move_and_slide(move_vec.normalized() * move_speed, Vector3(0,1,0))


# On Unit Selection
func on_select():
	$SelectionRing.show()

# On Unit Deselection

func on_deselect():
	$SelectionRing.hide()



#sets a path toward a new target
func move_to( target : Vector3):
	
	path = nav_parent.get_simple_path(global_transform.origin, target)
	print("move to called path =", path)
	path_idx = 0
	

