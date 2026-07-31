# A class that handles converting from a Class -> savable resource and vice versa
class_name ClassResourceConverter extends RefCounted
	
# Converts the classes to resources
func convert_to_resources(networkStructureToConvert: NetworkStructure) -> NetworkStructureResource:
	# The stuff to convert
	var connectionsToConvert: Dictionary[String, Connection] = networkStructureToConvert.Connections
	var positionalNodesToConvert: Dictionary[int, PositionalNode] = networkStructureToConvert.ConnectionPositonalNodes
	
	# The converted stuff
	var convertedNetworkStructure = NetworkStructureResource.new()
	
	# Converting the connections
	for connection in connectionsToConvert.values():
		var convertedConnection = ConnectionResource.new()
		convertedConnection.ID = connection.ID
		convertedConnection.StartNodeID = connection.StartNode.ID
		convertedConnection.EndNodeID = connection.EndNode.ID
		convertedConnection.Name = connection.Name
		convertedConnection.SpeedLimit = connection.SpeedLimit
		convertedNetworkStructure.Connections[connection.ID] = convertedConnection
	
	# Converting the positional nodes
	for positionalNode in positionalNodesToConvert.values():
		var convertedPositionalNode = PositionalNodeResource.new()
		convertedPositionalNode.ID = positionalNode.ID
		convertedPositionalNode.Position = positionalNode.Position
		convertedPositionalNode.ParentConnectionID = positionalNode.ParentConnection.ID
		convertedNetworkStructure.ConnectionPositonalNodes[positionalNode.ID] = convertedPositionalNode
		
	return convertedNetworkStructure

## Converts the resources to classes
#func convert_to_classes() -> NetworkStructure:
	
