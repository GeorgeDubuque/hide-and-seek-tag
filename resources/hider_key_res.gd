class_name HiderKeyRes extends Resource

@export var material: StandardMaterial3D
@export var hiderColor: globals.HiderColor

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.

# func _init(p_material: StandardMaterial3D, p_hiderColor: globals.HiderColor):
# 	material = p_material
# 	hiderColor = p_hiderColor