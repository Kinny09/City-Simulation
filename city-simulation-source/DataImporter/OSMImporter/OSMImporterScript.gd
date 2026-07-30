extends Node

## Node Variables
var RequestorOutput: Dictionary
var SimulationNetworkStructure: NetworkStructure = NetworkStructure.new()

## Constants (These will be temporary, just here for debugging purposes for now
# 53.7490293,-0.3974381,53.7510890,-0.3922175 - A small test area of Hull
# 53.715000,-0.4836188,53.8109399,-0.2109668 - All of Hull

const BBOX_COORDINATES_FOR_IMPORT: String = "53.7490293,-0.3974381,53.7510890,-0.3922175"
const BBOX_COORDINATES_FOR_SCALE: Vector4 = Vector4(53.715000,-0.4836188,53.8109399,-0.2109668)
const SCREEN_COORDINATES: Vector4 = Vector4(-2000, -2324, 2000, 2324)

## Node References
@onready var HTTPRequestNode = $HTTPRequest
@onready var DataImporter = $".."

## Would prob be a good idea to multithread this whole thing at some point, at the very least, make it run on a thread in the background so the graphics can still work
## On second through, this might actually be relativley difficult to mulithread. Or atleas, it'll need a complete rewrite

# -----------------------------------------------------------------------------------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------------------------------------------------------------------------------
func _ready() -> void:
	# Setting up the HTTP requestor
	var OverpassAPIHTTPRequestor: HTTPRequestor = HTTPRequestor.new(HTTPRequestNode, 10, 1.5)
	OverpassAPIHTTPRequestor.NameOfRequest = "Test HTTP Request"
	OverpassAPIHTTPRequestor.Header = "https://overpass-api.de/api/interpreter"
	OverpassAPIHTTPRequestor.ContentType = "application/x-www-form-urlencoded"
	OverpassAPIHTTPRequestor.BusyCodes = [429, 504, 502, 503]
	
	# Setting up signal connections
	OverpassAPIHTTPRequestor.status_changed.connect(print_out_http_status)
	OverpassAPIHTTPRequestor.http_request_finished.connect(request_complete)
	
	# Setting up test query
	OverpassAPIHTTPRequestor.Query = """
		[out:json][timeout:50];
		(
			way(%s)
			["highway"~"^(motorway|trunk|primary|secondary|tertiary|motorway_link|trunk_link|primary_link|secondary_link|tertiary_link|residential|unclassified|living_street|service)$"];
			>;
		);
		out;
	""" % [BBOX_COORDINATES_FOR_IMPORT]
	
	# Making the call and waiting for the result
	OverpassAPIHTTPRequestor.send_http_request_post()
	await OverpassAPIHTTPRequestor.http_request_finished
	
	# Setting up the OSM to Sim format converter
	var topLeftReferencePoint: ReferencePoint = ReferencePoint.new(SCREEN_COORDINATES[0], SCREEN_COORDINATES[1], BBOX_COORDINATES_FOR_SCALE[2], BBOX_COORDINATES_FOR_SCALE[1])
	var bottomRightReferencePoint: ReferencePoint = ReferencePoint.new(SCREEN_COORDINATES[2], SCREEN_COORDINATES[3], BBOX_COORDINATES_FOR_SCALE[0], BBOX_COORDINATES_FOR_SCALE[3])
	var OSMtoSimFormatConverter: OSMToSimConverter = OSMToSimConverter.new(topLeftReferencePoint, bottomRightReferencePoint)
	SimulationNetworkStructure = OSMtoSimFormatConverter.convert_roads_to_sim_format(SimulationNetworkStructure, RequestorOutput)
	
	# Tell the rest of the code that the importing is done
	DataImporter.DATA_IMPORTER_FINISHED.emit(SimulationNetworkStructure)
	
# -----------------------------------------------------------------------------------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------------------------------------------------------------------------------
## Prints out the current status of the HTTP request, temporary, will be replaced with a UI element
func print_out_http_status(newStatus: String):
	print(newStatus)
	
## Called when the HTTP request is fully complete
func request_complete(success: bool, result: Dictionary):
	if success == true:
		RequestorOutput = result
	if success == false:
		print("FAILED HTTP REQUEST SEE ERROR LOG")
