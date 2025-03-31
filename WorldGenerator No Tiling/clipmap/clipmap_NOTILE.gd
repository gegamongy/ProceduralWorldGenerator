
extends MeshInstance3D

@export var Player: Node3D
var wc = WorldConfiguration.new()
var terrain_snap_factor = 64


func _ready():
	
	initialize_shader()
	pass
	
	
func initialize_shader():
	var mat: ShaderMaterial = self.get_active_material(0)
	
	#Set shader parameters
	mat.set_shader_parameter('tile_size', wc.heightmap_texture_size)
	mat.set_shader_parameter('amplitude', wc.amplitude) #
	
	pass
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		self.global_position = snapped(
			Player.global_position,
			Vector3(terrain_snap_factor, 0, terrain_snap_factor)) * Vector3(1, 0, 1
		)
		
		
