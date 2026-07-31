# A class that handles converting from a Class -> savable resource and vice versa
class_name ClassResourceConverter extends RefCounted
	
# Converts the classes to resources
func convert_to_resources(networkStructureToConvert: NetworkStructure) -> NetworkStructureResource:
	# The stuff to convert
	var connectionsToConvert: Dictionary[String, Connection] = networkStructureToConvert.Connections
	var positionalNodesToConvert: Dictionary[int, PositionalNode] = networkStructureToConvert.ConnectionPositonalNodes
	
	# The converted stuff
	var convertedNetworkStructure = NetworkStructureResource.new()
	
	# Converting the positional nodes
	for positionalNode in positionalNodesToConvert.values():
		var convertedPositionalNode = PositionalNodeResource.new()
		convertedPositionalNode.ID = positionalNode.ID
		convertedPositionalNode.Position = positionalNode.Position
		for parentConnection in positionalNode.ParentConnections:
			convertedPositionalNode.ParentConnectionsID.append(parentConnection.ID)
		convertedNetworkStructure.ConnectionPositonalNodes[positionalNode.ID] = convertedPositionalNode
	
	# Converting the connections
	for connection in connectionsToConvert.values():
		var convertedConnection = ConnectionResource.new()
		convertedConnection.ID = connection.ID
		convertedConnection.StartNodeID = connection.StartNode.ID
		convertedConnection.EndNodeID = connection.EndNode.ID
		convertedConnection.Name = connection.Name
		convertedConnection.SpeedLimit = connection.SpeedLimit
		convertedNetworkStructure.Connections[connection.ID] = convertedConnection
		
	return convertedNetworkStructure

# Converts the resources to classes
func convert_to_classes(loadedNetworkStructureToConvert: NetworkStructureResource) -> NetworkStructure:
	# The stuff to convert
	var connectionsToConvert: Dictionary[String, ConnectionResource] = loadedNetworkStructureToConvert.Connections
	var positionalNodesToConvert: Dictionary[int, PositionalNodeResource] = loadedNetworkStructureToConvert.ConnectionPositonalNodes
	
	# The converted stuff
	var convertedNetworkStructure = NetworkStructure.new()
	
	# Converting the positional nodes
	for positionalNode in positionalNodesToConvert.values():
		var convertedPositionalNode = PositionalNode.new()
		convertedPositionalNode.ID = positionalNode.ID
		convertedPositionalNode.Position = positionalNode.Position
		convertedNetworkStructure.ConnectionPositonalNodes[positionalNode.ID] = convertedPositionalNode
		
	# Converting the connections
	for connection in connectionsToConvert.values():
		var convertedConnection = Connection.new()
		convertedConnection.ID = connection.ID
		convertedConnection.StartNode = convertedNetworkStructure.ConnectionPositonalNodes[connection.StartNodeID]
		convertedConnection.EndNode = convertedNetworkStructure.ConnectionPositonalNodes[connection.EndNodeID]
		convertedConnection.Name = connection.Name
		convertedConnection.SpeedLimit = connection.SpeedLimit
		convertedConnection.StartNode.ParentConnections.append(convertedConnection)
		convertedConnection.EndNode.ParentConnections.append(convertedConnection)
		convertedNetworkStructure.Connections[connection.ID] = convertedConnection
	
	return convertedNetworkStructure
	
