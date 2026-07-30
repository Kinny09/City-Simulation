## A class that holds positional data
class_name PositionalNode extends RefCounted

# Member Variables
var Position: Vector2
var ParentConnection: Connection

func _init(_Position):
	Position = _Position
