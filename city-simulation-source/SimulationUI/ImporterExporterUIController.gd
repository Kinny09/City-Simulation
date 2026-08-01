# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
# Importer Exporter UI Controller
# Controls all the signalling for the Importer Exporter UI
# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
extends Control

# ---------------------------------------------------------------------------------------------------------------------------------------
# Debugging Constants
# ---------------------------------------------------------------------------------------------------------------------------------------
const SUCCESS_MESSAGE: String = "Coordinates Valid"
const FAILIURE_MESSAGE: String = "Coordinates Not Valid"

# ---------------------------------------------------------------------------------------------------------------------------------------
# Member Variable Declaration
# ---------------------------------------------------------------------------------------------------------------------------------------
var BboxSelection: Array = [null, null, null, null]

# ---------------------------------------------------------------------------------------------------------------------------------------
# CODE
# ---------------------------------------------------------------------------------------------------------------------------------------
func _ready() -> void:
	%EditLatitude_L.VALID_INPUT_SUBMITTED.connect(func(output):
		if output != null:
			BboxSelection[2] = output.to_float()
			
		handle_bbox_inputs()
	)
	
	%EditLongitude_L.VALID_INPUT_SUBMITTED.connect(func(output):
		if output != null:
			BboxSelection[1] = output.to_float()
			
		handle_bbox_inputs()
	)
	
	%EditLatitude_R.VALID_INPUT_SUBMITTED.connect(func(output):
		if output != null:
			BboxSelection[0] = output.to_float()
			
		handle_bbox_inputs()
	)
	
	%EditLongitude_R.VALID_INPUT_SUBMITTED.connect(func(output):	
		if output != null:
			BboxSelection[3] = output.to_float()
			
		handle_bbox_inputs()
	)
	
## Logic for handling the bbox inputs
func handle_bbox_inputs():
	if !BboxSelection.has(null):
		%MapImporterFeedback.text = SUCCESS_MESSAGE
	
	else:
		%MapImporterFeedback.text = FAILIURE_MESSAGE
