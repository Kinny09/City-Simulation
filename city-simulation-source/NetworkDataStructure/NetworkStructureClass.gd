## A class that holds all the network data
class_name NetworkStructure extends RefCounted

# Member Variables
var Connections: Dictionary[String, Connection]
var ConnectionPositonalNodes: Dictionary[int, PositionalNode]
var Places: Dictionary

# Constructor
func _init():
	Connections = {}
	ConnectionPositonalNodes = {}
