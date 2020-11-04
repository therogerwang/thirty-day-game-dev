extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var is_visible = false
var m_pos = Vector2()
var start_sel_pos = Vector2()
const sel_box_col = Color(0, 1, 0)
const sel_box_line_width = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()



func _draw():
	if is_visible and start_sel_pos != m_pos:
		
		#draw box
		draw_line(start_sel_pos, Vector2(m_pos.x, start_sel_pos.y), sel_box_col, sel_box_line_width)
		draw_line(start_sel_pos, Vector2(start_sel_pos.x, m_pos.y), sel_box_col, sel_box_line_width)
		draw_line(m_pos, Vector2(m_pos.x, start_sel_pos.y), sel_box_col, sel_box_line_width)
		draw_line(m_pos, Vector2(start_sel_pos.x, m_pos.y), sel_box_col, sel_box_line_width)
