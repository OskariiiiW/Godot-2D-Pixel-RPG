extends Resource

class_name ItemElementType

var phys : Element = Element.new()

@export var physical : float
@export var magical : float
@export var poison : float
@export var curse : float
@export var elements : Array[Element] = [(Element.new()),(Element.new()),(Element.new()),(Element.new())]
#@export var test = {"Physical": 0, "Magical": 0, "Poison": 0, "Curse": 0} needs as many lines as old way

# add all elements as a default value to elements[]
