#@tool
class_name Clipmap

extends MeshInstance3D

@export var Player: Node3D
var wc = WorldConfiguration.new()
var terrain_scale = wc.terrain_scale_factor
var terrain_snap_factor = 64 * terrain_scale

var clipmap_scale

var debug_mode
var vp

func _input(event):
	if Input.is_action_just_pressed("toggle_debug"):
		vp.debug_draw  = (vp.debug_draw + 1 ) % 4
		
func _ready():
	RenderingServer.set_debug_generate_wireframes(true)
	vp = get_viewport()
	
	self.scale = Vector3(terrain_scale, terrain_scale, terrain_scale)
	initialize_shader()
	pass
	
	
func initialize_shader():
	var mat: ShaderMaterial = self.get_active_material(0)
	
	#Set shader parameters
	mat.set_shader_parameter('tile_size', wc.heightmap_texture_size)
	mat.set_shader_parameter('row_size', wc.tile_count)
	mat.set_shader_parameter('terrain_scale', wc.terrain_scale_factor)
	mat.set_shader_parameter('amplitude', wc.amplitude / self.scale.x ) #
	
	pass
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		self.global_position = snapped(
			Player.global_position,
			Vector3(terrain_snap_factor, 0, terrain_snap_factor)) * Vector3(1, 0, 1
		)
		
		
