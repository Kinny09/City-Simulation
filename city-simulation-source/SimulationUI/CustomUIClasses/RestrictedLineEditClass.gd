# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
# Restricted Line Edit
# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
## Allows for the limiting of the inputs to a specific type, as well as specifying error text and such. Emits a custom VALID_INPUT_SUBMITTED signal when accepted data has been inputted.
class_name RestrictedLineEdit extends LineEdit

# ---------------------------------------------------------------------------------------------------------------------------------------
# Enum Declaration
# ---------------------------------------------------------------------------------------------------------------------------------------
enum RestrictionType {NONE, FLOAT}

# ---------------------------------------------------------------------------------------------------------------------------------------
# Member Variable Declaration
# ---------------------------------------------------------------------------------------------------------------------------------------
# Exported Member Variables
@export var Restriction: RestrictionType
@export var GenericErrorMessage: String
@export var AllowedRange: Vector2

# Standard Member Variables
var DefaultPlaceholderText: String = self.placeholder_text

# ---------------------------------------------------------------------------------------------------------------------------------------
# Signalling
# ---------------------------------------------------------------------------------------------------------------------------------------
signal VALID_INPUT_SUBMITTED(output)

# ---------------------------------------------------------------------------------------------------------------------------------------
# CODE
# ---------------------------------------------------------------------------------------------------------------------------------------
# Setting up the input signal detection
func _ready() -> void:
	editing_toggled.connect(func(toggledOn):
		if !toggledOn && self.text != "":
			check_input_is_valid()
		else:
			self.placeholder_text = DefaultPlaceholderText
	)
	
## The method that actually handles all the restricting
func check_input_is_valid():
	var textInputted = self.text
	
	if Restriction == RestrictionType.NONE:
		VALID_INPUT_SUBMITTED.emit(textInputted)
	
	elif Restriction == RestrictionType.FLOAT:
		if !textInputted.is_valid_float():
			self.text = ""
			self.placeholder_text = GenericErrorMessage
		
		elif textInputted.is_valid_float() && textInputted.to_float() < AllowedRange[0] || textInputted.to_float() > AllowedRange[1]:
			self.text = ""
			self.placeholder_text = "Input is out of range: [%d, %d]" % [AllowedRange[0], AllowedRange[1]]
		
		else:
			VALID_INPUT_SUBMITTED.emit(textInputted)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
