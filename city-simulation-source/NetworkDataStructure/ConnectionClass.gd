## A class that holds connection data
class_name Connection extends RefCounted

# Member Variables
var Name: String
var StartNode: PositionalNode
var EndNode: PositionalNode

# Constructor
func _init(_Name: String, _StartNode: PositionalNode, _EndNode: PositionalNode):
	Name = _Name
	StartNode = _StartNode
	EndNode = _EndNode
