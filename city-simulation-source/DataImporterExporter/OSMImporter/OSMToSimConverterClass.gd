## A class that handles converting OSM data formats to the sim format
class_name OSMToSimConverter extends RefCounted

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
func convert_roads_to_sim_format(networkToEdit: NetworkStructure, input: Dictionary) -> NetworkStructure:
	# The nodes are converted into PositionalNodes to later be given parents once the connections are created.
	for element: Dictionary in input["elements"]:
		if element["type"] == "node":
			var positionOfPositionalNode: Vector2 = convert_long_lat_to_screen_XY(element["lat"], element["lon"])
			var newPositionalNode: PositionalNode = PositionalNode.new()
			newPositionalNode.ID = element["id"]
			newPositionalNode.Position = positionOfPositionalNode
			
			networkToEdit.ConnectionPositonalNodes[element["id"]] = newPositionalNode
	
	# The ways are converted to connections by running through the list of nodes in the way and turns them into connections
	for element: Dictionary in input["elements"]:
		if element["type"] == "way":
			# Presetting the tags that need to always have a result
			var speedLimit: int = 30
			
			# Grabs and sets the necessary tags
			var elementTags: Dictionary = element["tags"]
			for tagName in elementTags:
				match tagName:
					"maxspeed":
						var speed = elementTags["maxspeed"]
						speed = int(speed.get_slice(" ", 0))
						speedLimit = speed
			
			# Setting the start and end nodes of the connection
			var startNodeIndex: int = -1
			var endNodeIndex: int = 0
			
			while endNodeIndex < element["nodes"].size() - 1:
				startNodeIndex += 1
				endNodeIndex += 1
				
				var startNode: PositionalNode = networkToEdit.ConnectionPositonalNodes[element["nodes"][startNodeIndex]]
				var endNode: PositionalNode = networkToEdit.ConnectionPositonalNodes[element["nodes"][endNodeIndex]]
				
				# Creating the connections ID
				var connectionID: String = "%d:%s" % [element["id"], startNodeIndex]
				
				var newConnection: Connection = Connection.new()
				newConnection.ID = connectionID
				newConnection.StartNode = startNode
				newConnection.EndNode = endNode
				startNode.ParentConnection = newConnection
				endNode.ParentConnection = newConnection
				
				# Setting the name to either the name of the road or the connections ID depending on if the way has a name
				
				if element["tags"].has("name") == true:
					newConnection.Name = element["tags"]["name"]
				else:
					newConnection.Name = connectionID
					
				# Setting the connection tags
				newConnection.SpeedLimit = speedLimit
				
				# Adding the connection to the network
				networkToEdit.Connections[connectionID] = newConnection
				
	# Returning the network
	return networkToEdit

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
	
	
