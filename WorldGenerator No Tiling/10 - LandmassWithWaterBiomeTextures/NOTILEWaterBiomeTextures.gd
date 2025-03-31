extends WorldGenProcess

var wc = WorldConfiguration.new()

@onready var viewport = get_node('SubViewports').get_children()[0]

var tex_size = wc.heightmap_texture_size
var tex

var heightmap
var lake_depth_mask
var swamp_mask
var wetland_mask
var swamp_texture
var wetland_texture

var mat: ShaderMaterial

func _ready():
	
	heightmap = load('res://Images/LandmassesWithFlatWaterBiomes.tres')
	lake_depth_mask = load("res://Images/LakeDepthMask.tres")
	swamp_mask = load("res://Images/SwampMask.tres")
	wetland_mask = load("res://Images/WetlandMask.tres")
	swamp_texture = load("res://10 - LandmassWithWaterBiomeTextures/swamp_noise_texture.tres")
	wetland_texture = load("res://10 - LandmassWithWaterBiomeTextures/wetland_noise_texture.tres")
	
	viewport.size = Vector2(tex_size, tex_size)
	setupShader()
	
	tex = viewport.get_texture()
	await RenderingServer.frame_post_draw
	
	
	generateLandmassMap()
	
func setupShader():
	var rect = viewport.get_child(0)
	mat = rect.material
	
	mat.set_shader_parameter("heightmap", heightmap)
	mat.set_shader_parameter("lake_depth_mask", lake_depth_mask)
	mat.set_shader_parameter("swamp_mask", swamp_mask)
	mat.set_shader_parameter("wetland_mask", wetland_mask)
	mat.set_shader_parameter("swamp_texture", swamp_texture)
	mat.set_shader_parameter("wetland_texture", wetland_texture)
	

func generateLandmassMap():
	#For tiling - Iterate through each tile, and save the image
	var image = tex.get_image()
	var image_texture = ImageTexture.create_from_image(image)
	
	var path = 'res://Images/LandmassesWithWaterBiomeDetail.tres'
	ResourceSaver.save(image_texture, path)
	
	emit_signal("process_complete")
