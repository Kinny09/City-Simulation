## A class that handles converting OSM data formats to the sim format
class_name OSMToSimConverter extends RefCounted

## Add the ability to convert latitude and longitude into X and Y

func convert_to_sim_format(input: Dictionary) -> NetworkStructure:
	var simulationNetworkStructure: NetworkStructure = NetworkStructure.new()
	
	# The nodes are converted into PositionalNodes to later be given parents once the connections are created.
	for element: Dictionary in input["elements"]:
		if element["type"] == "node":
			var newPositionalNode: PositionalNode = PositionalNode.new(element["lon"], element["lat"])
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
	
	
