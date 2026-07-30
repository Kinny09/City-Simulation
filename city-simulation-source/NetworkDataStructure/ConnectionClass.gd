## A class that holds connection data
class_name Connection extends RefCounted

# Member Variables
var StartNode: PositionalNode
var EndNode: PositionalNode
var Name: String
var SpeedLimit: int

# Constructor
func _init(_StartNode: PositionalNode, _EndNode: PositionalNode):
	StartNode = _StartNode
	EndNode = _EndNode
