extends Node

## Node Variables
var OverpassAPIHTTPRequestor: HTTPRequestor
var RequestorOutput: Dictionary
var BboxCoordinates: String = "53.7490293,-0.3974381,53.7510890,-0.3922175"

## Node Refrences
@onready var HTTPRequestNode = $HTTPRequest

# -----------------------------------------------------------------------------------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------------------------------------------------------------------------------
func _ready() -> void:
	# Setting up the HTTP requestor
	OverpassAPIHTTPRequestor = HTTPRequestor.new(HTTPRequestNode, 10, 1.5)
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
	""" % [BboxCoordinates]
	
	# Making the call and waiting for the result
	OverpassAPIHTTPRequestor.send_http_request_post()
	await OverpassAPIHTTPRequestor.http_request_finished
	
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
