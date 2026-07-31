extends Node

## Node References
@onready var DataImporterExporter = $".."

## Member Variables
var SimulationSaveFileData: SimulationDataFile = SimulationDataFile.new()
var ImporterExporterConverter: ClassResourceConverter = ClassResourceConverter.new()

# Setting up the signal connections
func _ready() -> void:
	DataImporterExporter.SAVE_FILE.connect(save_file)
	DataImporterExporter.LOAD_FILE.connect(load_file)

# Saves the presented data
func save_file(NetworkToSave: NetworkStructure, SaveLocation: String):
	SimulationSaveFileData.SavedNetwork = ImporterExporterConverter.convert_to_resources(NetworkToSave)

	ResourceSaver.save(SimulationSaveFileData, SaveLocation)
	
# Loads the specified file
func load_file(SaveLocation: String):
	if FileAccess.file_exists(SaveLocation):
		SimulationSaveFileData = ResourceLoader.load(SaveLocation).duplicate(true)
		
		DataImporterExporter.DATA_IMPORTER_FINISHED.emit(ImporterExporterConverter.convert_to_classes(SimulationSaveFileData.SavedNetwork))
	
	else:
		print("ERROR: File does not exist")
		return null
