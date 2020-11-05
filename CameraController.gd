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
var start_sel_pos = Vector2()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	perform_camera_movement()
	
	
	var mouse_pos : Vector2 = get_viewport().get_mouse_position()
	if Input.is_action_just_pressed("ui_select"):
		selection_box.start_sel_pos = mouse_pos
		start_sel_pos = mouse_pos
		
			
			
	if Input.is_action_pressed("ui_select"):
		selection_box.m_pos = mouse_pos
		selection_box.is_visible = true
	else:
		selection_box.is_visible = false
		
	if Input.is_action_just_released("ui_select"):
		
		if abs(start_sel_pos.distance_to(mouse_pos)) > 8:
			update_player_selection(get_units_in_box(start_sel_pos, mouse_pos))
		else:
			update_player_selection([
				get_obj_under_mouse(mouse_pos, environ_collision_mask)
			])
		
		
	
func _physics_process(delta):
	
	if Input.is_action_just_pressed("ui_move_click"):
		var mouse_pos : Vector2 = get_viewport().get_mouse_position()
		move_all_units(mouse_pos)
			
#		print("clicked position %s" % clicked_pos )
	



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

With multiple units, will only select those on the player's team.
"""
func update_player_selection(obj_array: Array) -> void:
	
	var units : Array = []
	
	# deselect currently selected units
	for unit in selected_units:
		unit.call("on_deselect")
	
	if obj_array.size() == 1:
		
		# can select any unit and info
		if obj_array[0] is class_worker:
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


"""
Given two corners of a box, gets the objects of group 'units' within the box.

Returns the units within the drawn box as an array.
"""
func get_units_in_box(top_left: Vector2, bot_right: Vector2) -> Array:
	
	# deal with inverted box corners
	if top_left.x > bot_right.x:
		var tmp = top_left.x
		top_left.x = bot_right.x
		bot_right.x = tmp
	if top_left.y > bot_right.y:
		var tmp = top_left.y
		top_left.y = bot_right.y
		bot_right.y = tmp
	var box = Rect2(top_left, bot_right - top_left)
	
	# get the units in the box
	var box_selected_units = []
	for object in get_tree().get_nodes_in_group("units"):
		var unit : class_worker = object
		if box.has_point(camera.unproject_position(unit.global_transform.origin)):
			box_selected_units.append(unit)
	return box_selected_units
