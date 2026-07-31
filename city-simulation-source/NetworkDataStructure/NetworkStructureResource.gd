## A resource container for saving a network
class_name NetworkStructureResource extends Resource

# Member Variables
@export var Connections: Dictionary[String, ConnectionResource] = {}
@export var ConnectionPositonalNodes: Dictionary[int, PositionalNodeResource] = {}
