## A class that holds positional data
class_name PositionalNode extends RefCounted

# Member Variables
var X: float
var Y: float
var ParentConnection: Connection

func _init(_X: float, _Y: float):
	X = _X
	Y = _Y
