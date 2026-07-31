extends Node

## Constants (These will be temporary, just here for debugging purposes for now
# For now, all these bools are all mutually exclusive
const IMPORT_FROM_SAVED = true

const IMPORT_FROM_OSM = false
const SAVE_OSM_FILE = false

# 53.7490293,-0.3974381,53.7510890,-0.3922175 - A small test area of Hull
# 53.715000,-0.4836188,53.8109399,-0.2109668 - All of Hull
const BBOX_COORDINATES_FOR_IMPORT: String = "53.7490293,-0.3974381,53.7510890,-0.3922175"
const BBOX_COORDINATES_FOR_SCALE: Vector4 = Vector4(53.715000,-0.4836188,53.8109399,-0.2109668)
const SCREEN_COORDINATES: Vector4 = Vector4(-2000, -2324, 2000, 2324)

const SAVE_LOCATION = "user://SaveFile.tres"

## Node References
@onready var OSMImporter = $OSMImporter
@onready var SimImporterExporter = $SimImporterExporter

## Signals for importers
signal LOAD_FILE(SaveLocation: String)
signal IMPORT_OSM_FILE(BboxCoordinatesForImport: String, BboxCoordinatesForScale: Vector4, ScreenCoordinates: Vector4)
signal SAVE_FILE(NetworkStructureToSave: NetworkStructure, SaveLocation: String)

## Signals from importers
signal DATA_IMPORTER_FINISHED(Network: NetworkStructure)

func _ready() -> void:	
	if IMPORT_FROM_SAVED == true:
		LOAD_FILE.emit(SAVE_LOCATION)
		
	if IMPORT_FROM_OSM == true:
		IMPORT_OSM_FILE.emit(BBOX_COORDINATES_FOR_IMPORT, BBOX_COORDINATES_FOR_SCALE, SCREEN_COORDINATES)
		
	if SAVE_OSM_FILE == true:
		DATA_IMPORTER_FINISHED.connect(sendSaveSignal)
		IMPORT_OSM_FILE.emit(BBOX_COORDINATES_FOR_IMPORT, BBOX_COORDINATES_FOR_SCALE, SCREEN_COORDINATES)
	
func sendSaveSignal(networkStructureToSave: NetworkStructure):
	SAVE_FILE.emit(networkStructureToSave, SAVE_LOCATION)
