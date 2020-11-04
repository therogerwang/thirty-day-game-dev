extends Spatial


# Outside Objects
onready var camera = $Camera
onready var selection_box = $SelectionBox
const class_worker = preload("res://Assets/Worker.gd")
const speed = .3					# Camera Movement Speed
const ray_length = 500				#
var velocity = Vector3(0,0,0)		# Current Camera Velocity
var environ_collision_mask = 1

const player_team = 0				# Team identifier for the player
var selected_units : Array = []				# Array to hold selected units

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	perform_camera_movement()
	
	
func _physics_process(delta):
	
	if Input.is_action_just_pressed("ui_move_click"):
		var mouse_pos : Vector2 = get_viewport().get_mouse_position()
		move_all_units(mouse_pos)
			
#		print("clicked position %s" % clicked_pos )
	if Input.is_action_just_pressed("ui_select"):
		var mouse_pos : Vector2 = get_viewport().get_mouse_position()
		if get_obj_under_mouse(mouse_pos, environ_collision_mask) is class_worker:
			print("IS worker!!")



"""
Handles all camera controls and movement. Should be called every frame.
"""
func perform_camera_movement() -> void:
	#base camera controls
	# Zoom in and out
	if Input.is_action_just_released("ui_zoom_in"):
		camera.translate(Vector3(0,0,-1))
	
	if Input.is_action_just_released("ui_zoom_out"):
		camera.translate(Vector3(0,0,1))
	
	# Pan around
	if Input.is_action_pressed("ui_up"):
		velocity.z -= speed
	
	if Input.is_action_pressed("ui_down"):
		velocity.z += speed
	
	if Input.is_action_pressed("ui_right"):
		velocity.x += speed
		
	if Input.is_action_pressed("ui_left"):
		velocity.x -= speed
	
	#update camera controller velocity
	global_translate(velocity)
	velocity.x = 0
	velocity.z= 0

"""
Performs a raycast from mouse position using raycast_from_mouse().

Returns the 3D coordinates of the intersection of the ray and the first collidable
object. If no valid collision detected, then returns null.
"""
func get_mouse_raycast_collision_coords(mouse_pos, collision_mask):
	var space_state = get_world().direct_space_state
	var ray = raycast_from_mouse(mouse_pos)
	var ray_start = ray[0]
	var ray_end = ray[1]
	
	var result: Dictionary = space_state.intersect_ray(ray_start, ray_end,
							[self], collision_mask)
	
	if result.size() > 0: #catch nonmap click
		return result["position"]
	else:
		return null


"""
Performs a raycast from mouse position.
Returns an array of [start_ray position, end_ray_position] representing the ray.
"""
func raycast_from_mouse(mouse_pos: Vector2) -> Array:
	var ray_origin: Vector3 = camera.project_ray_origin(mouse_pos)
	var ray_end: Vector3 = ray_origin + camera.project_ray_normal(mouse_pos) * ray_length 
	
	return [ray_origin, ray_end]


"""
Given a mouse position, sends move orders to all units to that position raycasted
in 3D space.
"""
func move_all_units(mouse_pos: Vector2) -> void:
	var clicked_pos = get_mouse_raycast_collision_coords(mouse_pos, environ_collision_mask)
	if clicked_pos == null:
		#invalid click
		return
	print("clicked position ", clicked_pos)
	get_tree().call_group("units","move_to", clicked_pos)
#





################ UNIT SELECTION ######################
"""
Given an array of objects to select, checks each obj,and updates the class's 
selected_units array and performs routines associated with unit selection on each unit.

"""
func select_units(obj_array: Array) -> void:
	
	var units : Array = []
	
	# deselect currently selected units
	for unit in selected_units:
		unit.call("on_deselect")
	
	if obj_array.size() == 1:
		# can select any unit and info
		var unit : class_worker = obj_array[0]
		unit.on_select()
		units = obj_array
	else:
		# can only select units of player's team. also handles 0 case
		for unit in obj_array:
			if unit is class_worker:
				if unit.team == Globals.TEAMS.PLAYER:
					units.append(unit)
					unit.on_select()
					
	selected_units = units


################ MISC HELPER FUNCTIONS ######################

"""
Given a mouse position and a collision mask, gets the object directly under
the current mouse position in 3D space.

Returns the object node directly under mouse_pos and on the same collision space
if one exists. Otherwise, returns null.
"""
func get_obj_under_mouse(mouse_pos: Vector2, collision_mask):
	
	# raycast and get ray collision information
	var space_state = get_world().direct_space_state
	var ray: Array = raycast_from_mouse(mouse_pos)
	var ray_start = ray[0]
	var ray_end = ray[1]
	var selected_dict: Dictionary = space_state.intersect_ray(ray_start, ray_end,
							[self], collision_mask)
	
	if selected_dict.empty():
		#nothing selected
		return
	
	#get collided obj
	return selected_dict["collider"]
