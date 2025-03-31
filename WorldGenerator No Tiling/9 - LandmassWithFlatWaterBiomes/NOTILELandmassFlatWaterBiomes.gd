extends WorldGenProcess

var wc = WorldConfiguration.new()

@onready var viewport = get_node('SubViewport')
@onready var rect = get_node("SubViewport/ColorRect")

var heightmap
var water_biome_mask
var water_biome_altitude

var tex_size = wc.heightmap_texture_size
var tex

var mat: ShaderMaterial 

func _ready():
	heightmap = load("res://Images/LandmassesWithFaultlineDetail.tres")
	water_biome_mask = load("res://Images/WaterBiomes.tres")
	water_biome_altitude = load("res://Images/WaterBiomesWithAltitude.tres")

	#set viewport size
	viewport.size = Vector2(tex_size, tex_size)
	setup_shader()
	
	tex = viewport.get_texture()
	await RenderingServer.frame_post_draw

	generateLandmassMap()
	

func setup_shader():
	mat = rect.material
	mat.set_shader_parameter("heightmap", heightmap)
	mat.set_shader_parameter("water_biome_mask", water_biome_mask)
	mat.set_shader_parameter("water_biome_altitude", water_biome_altitude)


func generateLandmassMap():
	#For tiling - Iterate through each tile, and save the image
	var image = tex.get_image()
	image.save_png('res://Images/LandmassesWithFlatWaterBiomes.png')
	var image_texture = ImageTexture.create_from_image(image)
	
	var path = 'res://Images/LandmassesWithFlatWaterBiomes.tres'
	
	ResourceSaver.save(image_texture, path)
	print('Saved res://Images/LandmassesWithFlatWaterBiomes.tres')
	emit_signal('process_complete')
