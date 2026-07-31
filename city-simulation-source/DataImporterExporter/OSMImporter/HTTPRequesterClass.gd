## A class that handles HTTP requests
class_name HTTPRequestor extends RefCounted

# Private Member Variables
var HTTPRequestNode: HTTPRequest
var MaxRetries: int
var RetryDelay: float
var RetryCount: int

# Public Member Variables
var NameOfRequest: String
var Header: String
var ContentType: String
var Query: String
var BusyCodes: Array[int]
var Status: String = ""

# Signals
signal status_changed(status: String)
signal http_request_finished(success: bool, result: Dictionary)

# Constructor
func _init(_HTTPRequestNode: HTTPRequest, _MaxRetries: int, _RetryDelay: float):
	HTTPRequestNode = _HTTPRequestNode
	MaxRetries = _MaxRetries
	RetryDelay = _RetryDelay
	
	# Connecting to the on_request_completed method so the code knows when an API call is finished
	HTTPRequestNode.request_completed.connect(check_if_request_was_successful)
	
# Creates and send the HTTP request
func send_http_request_post():
	if RetryCount < 1:
		update_status("\nStarting HTTP request: %s" % [NameOfRequest])
		
	HTTPRequestNode.request(
		Header,
		["Content-Type: %s" % [ContentType]],
		HTTPClient.METHOD_POST,
		"data=%s" % [Query.uri_encode()]
	)

## The function and process the API calls response. If the API call is a busy code, it then attempt to try the call again 10 more times before giving up.
func check_if_request_was_successful(_result, response_code, _headers, body):
	if response_code in BusyCodes:
		if RetryCount < MaxRetries:
			RetryCount += 1
			update_status("\nServer busy. Retrying in %s seconds..." % [RetryDelay])
			await Engine.get_main_loop().create_timer(RetryDelay).timeout
			RetryDelay *= 1.5  # Exponential delay to prevent spamming of the API server
			send_http_request_post()
			return
		else:
			update_status("\nMax retries reached. Giving up. Restart Program")
			return
	elif response_code not in BusyCodes and response_code != 200:
		update_status("Error occured with Overpass API, error code: %s. Restart the program and check your connected to the internet." % [response_code])
		http_request_finished.emit(false, null)
		return

	# Resets the variables for the retry logic as the call was a success
	RetryCount = 0
	RetryDelay = 1.5
	
	# Turns the returned body into a dictionary
	var responseText = body.get_string_from_utf8()
	var returnedJson = JSON.parse_string(responseText)

	if returnedJson == null:
		update_status("\nJSON parse error. Raw body:\n %s" % [responseText])
		http_request_finished.emit(false, null)
	else:
		update_status("\nHTTP Request successfully Complete.")
		http_request_finished.emit(true, returnedJson)
		return
		
func update_status(lineToAdd):
	Status += lineToAdd
	status_changed.emit(Status)
	
