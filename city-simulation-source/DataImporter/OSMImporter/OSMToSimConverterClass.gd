## A class that handles converting OSM data formats to the sim format
class_name OSMToSimConverter extends RefCounted

## Add the ability to convert latitude and longitude into X and Y

 # Constants
const RADIUS_OF_EARTH = 6371

# Private Member Variables
var TopLeftReferencePoint: ReferencePoint
var BottomRightReferencePoint: ReferencePoint

# Constructor
func _init(_TopLeftReferencePoint: ReferencePoint, _BottomRightReferencePoint: ReferencePoint):
	TopLeftReferencePoint = _TopLeftReferencePoint
	BottomRightReferencePoint = _BottomRightReferencePoint
	
	# Setting the global X and Y's of the reference points
	var topLeftReferencePointGlobalXY = convert_long_lat_to_global_XY(TopLeftReferencePoint.Latitude, TopLeftReferencePoint.Longitude)
	TopLeftReferencePoint.GlobalX = topLeftReferencePointGlobalXY[0]
	TopLeftReferencePoint.GlobalY = topLeftReferencePointGlobalXY[1]
	
	var bottomRightReferencePointGlobalXY = convert_long_lat_to_global_XY(BottomRightReferencePoint.Latitude, BottomRightReferencePoint.Longitude)
	BottomRightReferencePoint.GlobalX = bottomRightReferencePointGlobalXY[0]
	BottomRightReferencePoint.GlobalY = bottomRightReferencePointGlobalXY[1]

# Converts the format from OSM to the format that the simulation uses, returns a fully populated NetworkStructure
func convert_to_sim_format(input: Dictionary) -> NetworkStructure:
	var simulationNetworkStructure: NetworkStructure = NetworkStructure.new()
	
	# The nodes are converted into PositionalNodes to later be given parents once the connections are created.
	for element: Dictionary in input["elements"]:
		if element["type"] == "node":
			var positionOfPositionalNode: Vector2 = convert_long_lat_to_screen_XY(element["lat"], element["lon"])
			var newPositionalNode: PositionalNode = PositionalNode.new(positionOfPositionalNode)
			
			simulationNetworkStructure.ConnectionPositonalNodes[element["id"]] = newPositionalNode
	
	# The ways are converted to connections by running through the list of nodes in the way and turns them into connections
	for element: Dictionary in input["elements"]:
		if element["type"] == "way":
			var connectionName: String = "%s" % [element["id"]] # TEMPORARY Make a proper setup for this that actually grabs the real name of the road
			var startNodeIndex: int = -1
			var endNodeIndex: int = 0
			
			while endNodeIndex < element["nodes"].size() - 1:
				startNodeIndex += 1
				endNodeIndex += 1
				
				var startNode = simulationNetworkStructure.ConnectionPositonalNodes[element["nodes"][startNodeIndex]]
				var endNode = simulationNetworkStructure.ConnectionPositonalNodes[element["nodes"][endNodeIndex]]
				
				var newConnection: Connection = Connection.new(connectionName, startNode, endNode)
				startNode.ParentConnection = newConnection
				endNode.ParentConnection = newConnection
				
				simulationNetworkStructure.Connections[element["id"]] = newConnection
	
	return simulationNetworkStructure

func convert_long_lat_to_global_XY(longitude : float, latitude : float) -> Vector2:
	var x = RADIUS_OF_EARTH * longitude * cos((TopLeftReferencePoint.Latitude + BottomRightReferencePoint.Latitude)/2)
	var y = RADIUS_OF_EARTH * latitude
	return Vector2(x, y)
	
func convert_long_lat_to_screen_XY(longitude : float, latitude : float) -> Vector2:
	var position: Vector2 = convert_long_lat_to_global_XY(longitude, latitude)
	var x = ((position.x-TopLeftReferencePoint.GlobalX)/(BottomRightReferencePoint.GlobalX - TopLeftReferencePoint.GlobalX))
	var y = ((position.y-TopLeftReferencePoint.GlobalY)/(BottomRightReferencePoint.GlobalY - TopLeftReferencePoint.GlobalY))
	
	x = TopLeftReferencePoint.ScreenX + (BottomRightReferencePoint.ScreenX - TopLeftReferencePoint.ScreenX) * x
	y = TopLeftReferencePoint.ScreenY + (BottomRightReferencePoint.ScreenY - TopLeftReferencePoint.ScreenY) * y
	
	return Vector2(x, y)
	
	
