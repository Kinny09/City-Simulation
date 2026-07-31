extends Node

## Constants
const SAVE_LOCATION = "user://SaveFile.tres"

## Node References
@onready var DataImporter = $".."

## Member Variables
var SimulationSaveFileData: SimulationDataFile = SimulationDataFile.new()
var ImporterExporterConverter: ClassResourceConverter = ClassResourceConverter.new()

## Godot does not allow cyclical references when saving items, so make a way to turn these references into ID's when saving and 
## the ID's into references when loading.


func _ready() -> void:
	## Debug Saver Call
	#DataImporter.DATA_IMPORTER_FINISHED.connect(save_file)
	
	# Debug loader call
	await Engine.get_main_loop().create_timer(1).timeout
	var loadedNetworkStructure: NetworkStructure = load_file()
	DataImporter.DATA_IMPORTER_FINISHED.emit(loadedNetworkStructure)

func save_file(NetworkToSave: NetworkStructure):
	SimulationSaveFileData.SavedNetwork = ImporterExporterConverter.convert_to_resources(NetworkToSave)

	ResourceSaver.save(SimulationSaveFileData, SAVE_LOCATION)
	
func load_file() -> NetworkStructure:
	if FileAccess.file_exists(SAVE_LOCATION):
		SimulationSaveFileData = ResourceLoader.load(SAVE_LOCATION).duplicate(true)
		
		return ImporterExporterConverter.convert_to_classes(SimulationSaveFileData.SavedNetwork)
	
	else:
		return null
