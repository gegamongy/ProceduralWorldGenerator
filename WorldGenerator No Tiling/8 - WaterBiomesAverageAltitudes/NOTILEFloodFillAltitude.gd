extends WorldGenProcess

# Load the images (replace with your actual image paths)
var water_biome_mask: Image
var heightmap: Image
var output_image: Image

# Function to calculate the average height of a region using flood fill
func main():
	
	#print(water_image_data.size(), ", ", heightmap_image_data.size())
	var average_height_image_data = calculate_average_height(water_biome_mask, heightmap)
	save_image_data(average_height_image_data)
	
	emit_signal('process_complete')
	

func calculate_average_height(water_biome_mask: Image, heightmap: Image):
	
	output_image = Image.new()
	output_image.copy_from(water_biome_mask)
	
	var width = water_biome_mask.get_width()
	var height = water_biome_mask.get_height()

	# Set to track already processed regions
	var processed_regions = {}
	
	for y in range(height):
		for x in range(width):
			
			var water_biome_pixel_color = water_biome_mask.get_pixel(x, y) #img.get_pixel(x, y)
			
			# Skip if the pixel is part of a region we've already processed or it's not a lake
			if processed_regions.has(water_biome_pixel_color) or water_biome_pixel_color == Color.BLACK:
				continue
			
			# Use flood fill to collect all pixels belonging to the current lake (region)
			var region_pixels = _flood_fill_collect_region(output_image, water_biome_mask, x, y, water_biome_pixel_color)
			
			# Calculate the average height for the region
			var total_height = 0.0
			
			for pixel in region_pixels:
				total_height += heightmap.get_pixel(pixel.x, pixel.y).r  # Assuming heightmap stores height in red channel
			
			var average_height = total_height / region_pixels.size()
			
			# Assign the average height to all the region's pixels in the output image
			for pixel in region_pixels:
				output_image.set_pixel(pixel.x, pixel.y, Color(average_height, average_height, average_height))
				
			
			# Mark this region as processed
			processed_regions[water_biome_pixel_color] = true
	
	
	return output_image

# Flood fill function to collect all pixels of a region
func _flood_fill_collect_region(output_image: Image, image: Image, start_x: int, start_y: int, region_color: Color) -> Array:
	
	var pixels = []
	var stack = []
	stack.append(Vector2(start_x, start_y))
	
	var width = image.get_width()
	var height = width
	
	while stack.size() > 0:
		var current = stack.pop_back()
		var x = int(current.x)
		var y = int(current.y)
		
		var pixel_color = image.get_pixel(x, y)
		
		if pixel_color == region_color:
			pixels.append(Vector2(x, y))
			image.set_pixel(x, y, Color.BLACK)  # Mark as visited by changing the color
			
			# Add neighboring pixels to the stack
			if x > 0: stack.append(Vector2(x - 1, y))
			if x < width - 1: stack.append(Vector2(x + 1, y))
			if y > 0: stack.append(Vector2(x, y - 1))
			if y < height - 1: stack.append(Vector2(x, y + 1))
	
	return pixels

func save_image_data(image: Image):
	
	var image_texture = ImageTexture.create_from_image(image)
	image.save_png("res://Images/WaterBiomesWithAltitude.png")
	ResourceSaver.save(image_texture, "res://Images/WaterBiomesWithAltitude.tres")
	print("Saved WaterBiomeUniqueColors.tres")

# Call the function to start processing
func _ready():
	
	water_biome_mask = load("res://Images/WaterBiomesUniqueColors.tres").get_image()
	heightmap = load("res://Images/LandmassesWithFaultlineDetail.tres").get_image()

	main()
