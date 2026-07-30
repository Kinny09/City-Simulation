class_name ReferencePoint extends RefCounted
	
# Member Variables
var ScreenX: float
var ScreenY: float
var Latitude: float
var Longitude: float
var GlobalX: float
var GlobalY: float

func _init(_ScreenX, _ScreenY, _Latitude, _Longitude):
	ScreenX = _ScreenX
	ScreenY = _ScreenY
	Latitude = _Latitude
	Longitude = _Longitude
	GlobalX = 0.0
	GlobalY = 0.0
