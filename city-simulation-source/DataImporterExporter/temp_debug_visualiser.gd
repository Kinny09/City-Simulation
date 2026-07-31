extends Node2D

## Node References
@onready var DataImporter = $"../DataImporterExporter"

func _ready() -> void:
	DataImporter.DATA_IMPORTER_FINISHED.connect(start_visualisation)

func start_visualisation(Network: NetworkStructure):
	for connection in Network.Connections.values():
		var newLine = Line2D.new()
		newLine.width = 2
		newLine.add_point(connection.StartNode.Position)
		newLine.add_point(connection.EndNode.Position)
		newLine.visible = true
		
		add_child(newLine)
