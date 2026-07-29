## A class that represents a place
class_name Place extends RefCounted

# Member Variables
var Name: String
var PlacePositionalPoints: Array[PositionalNode]

# Constructor
func _init(_Name: String, _PlacePositionalPoints: Array[PositionalNode]):
	Name = _Name
	PlacePositionalPoints = _PlacePositionalPoints
