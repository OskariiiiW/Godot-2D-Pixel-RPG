extends MarginContainer

var isDragging = false
var movedToTop = false # dunno if even works
var parent
var offset

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			offset = get_local_mouse_position()
			isDragging = true

func _process(_delta): # UI drag
	if isDragging:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var pos = get_viewport().get_mouse_position() - offset;

			if (parent != null):
				pos -= parent.global_position

				var _w = parent.size.x - size.x
				var _h = parent.size.y - size.y

				if (pos.x <= 0):
					pos.x = 0
				elif (pos.x > _w):
					pos.x = _w

				if (pos.y <= 0):
					pos.y = 0
				elif (pos.y > _h):
					pos.y = _h
			if !movedToTop && parent != null: # test
				parent.move_child(self, parent.get_child_count())
				movedToTop = true

			position = pos
		else:
			isDragging = false
			movedToTop = false
