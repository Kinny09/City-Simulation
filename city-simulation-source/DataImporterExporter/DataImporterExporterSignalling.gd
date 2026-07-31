# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
# DATA IMPORTER EXPORTER
# Handles the signalling and the inputs for all the data importing, saving and loading
# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------

extends Node

# ---------------------------------------------------------------------------------------------------------------------------------------
# Debugging Constants (These will be temporary, just here for debugging purposes for now
# ---------------------------------------------------------------------------------------------------------------------------------------
# For now, all these bools are all mutually exclusive
const IMPORT_FROM_SAVED = true
const IMPORT_FROM_OSM = false
const SAVE_OSM_FILE = false

# Data for the importing of OSM data
const BBOX_COORDINATES_FOR_IMPORT: String = "53.7490293,-0.3974381,53.7510890,-0.3922175"
const BBOX_COORDINATES_FOR_SCALE: Vector4 = Vector4(53.715000,-0.4836188,53.8109399,-0.2109668)
const SCREEN_COORDINATES: Vector4 = Vector4(-2000, -2324, 2000, 2324)
# 53.7490293,-0.3974381,53.7510890,-0.3922175 - A small test area of Hull
# 53.715000,-0.4836188,53.8109399,-0.2109668 - All of Hull

# The location the game will look for when saving and loading
const SAVE_LOCATION = "user://TestArea.tres"
# Hull is saved in "user://HullSave.tres"
# Small test area Hull is save in "user://TestArea.tres"

# ---------------------------------------------------------------------------------------------------------------------------------------
# Node References
# ---------------------------------------------------------------------------------------------------------------------------------------
@onready var OSMImporter = $OSMImporter
@onready var SimImporterExporter = $SimImporterExporter

# ---------------------------------------------------------------------------------------------------------------------------------------
# Signalling
# ---------------------------------------------------------------------------------------------------------------------------------------
# Signals for importers
signal LOAD_FILE(SaveLocation: String)
signal IMPORT_OSM_FILE(BboxCoordinatesForImport: String, BboxCoordinatesForScale: Vector4, ScreenCoordinates: Vector4)
signal SAVE_FILE(NetworkStructureToSave: NetworkStructure, SaveLocation: String)

# Signals from importers
signal DATA_IMPORTER_FINISHED(Network: NetworkStructure)


# ---------------------------------------------------------------------------------------------------------------------------------------
# CODE
# ---------------------------------------------------------------------------------------------------------------------------------------
func _ready() -> void:	
	if IMPORT_FROM_SAVED == true:
		LOAD_FILE.emit(SAVE_LOCATION)
		
	if IMPORT_FROM_OSM == true:
		IMPORT_OSM_FILE.emit(BBOX_COORDINATES_FOR_IMPORT, BBOX_COORDINATES_FOR_SCALE, SCREEN_COORDINATES)
		
	if SAVE_OSM_FILE == true:
		DATA_IMPORTER_FINISHED.connect(send_save_signal)
		IMPORT_OSM_FILE.emit(BBOX_COORDINATES_FOR_IMPORT, BBOX_COORDINATES_FOR_SCALE, SCREEN_COORDINATES)
	
## Sends the signal to save the file once it's received the OSM import
func send_save_signal(networkStructureToSave: NetworkStructure):
	SAVE_FILE.emit(networkStructureToSave, SAVE_LOCATION)
