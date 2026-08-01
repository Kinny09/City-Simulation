# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
# Map Viewport
# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
## A custom UI class that shows a small map for bbox selection purposes
class_name MapViewportClass extends PanelContainer

# ---------------------------------------------------------------------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------------------------------------------------------------------
const KEYS_TO_CONSUME_IF_MOUSE_INSIDE_VIEWPORT: Array = [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_LEFT]
const KEYS_TO_CONSUME_IF_VIEWPORT_FOCUSED: Array = [KEY_DOWN, KEY_UP, KEY_LEFT, KEY_RIGHT, MOUSE_BUTTON_MIDDLE]
const MOVE_SPEED: float = 500.0

# ---------------------------------------------------------------------------------------------------------------------------------------
# Member Variable Declaration
# ---------------------------------------------------------------------------------------------------------------------------------------
var MouseInViewport: bool
var LeftKeyPressed: bool
var RightKeyPressed: bool
var UpKeyPressed: bool
var DownKeyPressed: bool
var LeftMouseKeyPressed: bool
var CurrentSelection: Vector4
var Selector: Panel

@onready var SelectorAsset = preload("res://SimulationUI/CustomUIClasses/MapViewport/selector.tscn")

@onready var pointer = preload("res://SimulationUI/CustomUIClasses/MapViewport/pointer.tscn")

# ---------------------------------------------------------------------------------------------------------------------------------------
# CODE
# ---------------------------------------------------------------------------------------------------------------------------------------
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Makes sure the map isn't consuming inputs when it first loads
	set_process_input(false)
	set_process(false)
	
	# Signal that the viewport has been focused on
	%MapViewportContainer.focus_entered.connect(func():
		print("Map Focused")
		
		# Outlines the map container so it's clear that its been selected
		var visualiserContainerOutlined: StyleBoxFlat = StyleBoxFlat.new()
		visualiserContainerOutlined.border_width_left = 2
		visualiserContainerOutlined.border_width_top = 2
		visualiserContainerOutlined.border_width_right = 2
		visualiserContainerOutlined.border_width_bottom = 2
		visualiserContainerOutlined.border_color = Color(1,1,1,1)
		visualiserContainerOutlined.draw_center = true
		self.add_theme_stylebox_override("panel", visualiserContainerOutlined)
		
		# Tells the code to start consuming keyboard inputs
		set_process_input(true)
		set_process(true)
	)
	
	# Signal that the viewport has been unfocused on
	%MapViewportContainer.focus_exited.connect(func():
		print("Map unfocused")
		
		# Removes the outline
		self.remove_theme_stylebox_override("panel")
		
		# Tells the code to stop consuming keyboard inputs
		set_process_input(false)
		set_process(false)
	)
	
	# Signal that the mouse has entered the viewport
	%MapViewportContainer.mouse_entered.connect(func():
		MouseInViewport = true
	)
	
	# Signal that the mouse has exited the viewport
	%MapViewportContainer.mouse_exited.connect(func():
		MouseInViewport = false
	)

# Logic for handling the map viewports inputs
func _input(inputEvent: InputEvent) -> void:
	#print(inputEvent)
	
	# Handling zooming in and out
	if inputEvent is InputEventMouseButton && KEYS_TO_CONSUME_IF_MOUSE_INSIDE_VIEWPORT.has(inputEvent.button_index) && MouseInViewport:
		if inputEvent.button_index == MOUSE_BUTTON_WHEEL_UP:
			%MapViewportCamera.zoom += Vector2(0.1, 0.1)
		if inputEvent.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			%MapViewportCamera.zoom -= Vector2(0.1, 0.1)
		%MapViewportCamera.zoom = %MapViewportCamera.zoom.clamp(Vector2(0.2, 0.2), Vector2(11.0, 11.0))
		get_viewport().set_input_as_handled()
		
	# Handling left click inputs
	if inputEvent is InputEventMouseButton && KEYS_TO_CONSUME_IF_MOUSE_INSIDE_VIEWPORT.has(inputEvent.button_index) && MouseInViewport:
		if inputEvent.button_index == MOUSE_BUTTON_LEFT:
			# Getting the local positon of the mouse in the viewport
			var viewPortMousePosition = %SubViewport.get_canvas_transform().affine_inverse() * (%MapViewportContainer.get_local_mouse_position())
			
			# What to do at the beginning of the drag
			if inputEvent.pressed:
				for child in %Visualiser.get_children():
					child.queue_free()
				
				LeftMouseKeyPressed = true
				CurrentSelection[0] = viewPortMousePosition.x
				CurrentSelection[1] = viewPortMousePosition.y
				Selector = SelectorAsset.instantiate()
				Selector.visible = false
				%Visualiser.add_child(Selector)
			
			# What to do at the end of the drag
			else:
				LeftMouseKeyPressed = false
				CurrentSelection[2] = viewPortMousePosition.x
				CurrentSelection[3] = viewPortMousePosition.y
				
		get_viewport().set_input_as_handled()
		
	# Handling arrow key movement around the viewport
	if inputEvent is InputEventKey && KEYS_TO_CONSUME_IF_VIEWPORT_FOCUSED.has(inputEvent.keycode):
		if inputEvent.keycode == KEY_LEFT:
			LeftKeyPressed = inputEvent.pressed
		if inputEvent.keycode == KEY_RIGHT:
			RightKeyPressed = inputEvent.pressed
		if inputEvent.keycode == KEY_UP:
			UpKeyPressed = inputEvent.pressed
		if inputEvent.keycode == KEY_DOWN:
			DownKeyPressed = inputEvent.pressed
		get_viewport().set_input_as_handled()
		
	# Handling left click drags
	if LeftMouseKeyPressed && inputEvent is InputEventMouseMotion:
		Selector.visible = true
		var viewPortMousePosition = %SubViewport.get_canvas_transform().affine_inverse() * (%MapViewportContainer.get_local_mouse_position()).abs()
		CurrentSelection[2] = viewPortMousePosition.x
		CurrentSelection[3] = viewPortMousePosition.y
		var minumumX = minf(CurrentSelection[0], CurrentSelection[2])
		var minumumY = minf(CurrentSelection[1], CurrentSelection[3])
		var maxiumumX = maxf(CurrentSelection[0], CurrentSelection[2]) - minumumX
		var maxiumumY = maxf(CurrentSelection[1], CurrentSelection[3]) - minumumY
		
		Selector.position = Vector2(minumumX, minumumY)
		Selector.size = Vector2(maxiumumX, maxiumumY)

func _process(delta: float) -> void:
	if LeftKeyPressed:
		%MapViewportCamera.position.x -= MOVE_SPEED * delta
	if RightKeyPressed:
		%MapViewportCamera.position.x += MOVE_SPEED * delta
	if UpKeyPressed:
		%MapViewportCamera.position.y -= MOVE_SPEED * delta
	if DownKeyPressed:
		%MapViewportCamera.position.y += MOVE_SPEED * delta
