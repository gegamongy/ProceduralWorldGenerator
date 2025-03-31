extends WorldGenProcess

# Load the images (replace with your actual image paths)
var water_biome_masks: Texture2DArray
var heightmaps: Texture2DArray

func create_image_data():
	var water_image_data = {}
	var heightmap_image_data = {}
	
	var grid_size = sqrt(len(water_biome_masks._images))

	var first_image = water_biome_masks._images[0]
	
	var width = first_image.get_width()
	var height = first_image.get_height()
	
	for i in range(len(water_biome_masks._images)):
		
		var water_img = water_biome_masks._images[i]
		var height_img = heightmaps._images[i]
		
		#iVec2 Position of the current image in images array.
		var coord_x = int(i / grid_size)
		var coord_y = i % int(grid_size)
		
		#Construct Image Data
		for y in range(height):
			for x in range(width):
				#Coordinates in Image Data Dictionary
				var img_data_x = coord_x * width + x
				var img_data_y = coord_y * height + y
				
				#Get color from original image
				var water_pixel_color = water_img.get_pixel(x, y)
				var height_pixel_color = height_img.get_pixel(x, y)
				
				water_image_data[Vector2(img_data_x, img_data_y)] = water_pixel_color
				heightmap_image_data[Vector2(img_data_x, img_data_y)] = height_pixel_color
	
	return [water_image_data, heightmap_image_data]

# Function to calculate the average height of a region using flood fill
func main():
	
	#Construct Image Data
	var image_data = create_image_data()
	var water_image_data = image_data[0]
	var heightmap_image_data = image_data[1]
	
	#print(water_image_data.size(), ", ", heightmap_image_data.size())
	var average_height_image_data = calculate_average_height(water_image_data, heightmap_image_data)

	save_image_data(average_height_image_data)
	
	emit_signal('process_complete')
	

func calculate_average_height(water_image_data: Dictionary, heightmap_image_data: Dictionary):
	var first_image = water_biome_masks._images[0]
	
	#Copy water Image data
	var output_image_data = water_image_data
	
	#Get width and height from first image in arrays.
	var width = first_image.get_width()
	var height = first_image.get_height()

	#Loop through image data and perform flood fill.
	var img_data_width = width * sqrt(len(water_biome_masks._images))
	var img_data_height = height * sqrt(len(water_biome_masks._images))

	# Set to track already processed regions
	var processed_regions = {}
	
	
	
	for y in range(img_data_height):
		for x in range(img_data_width):
			
			var water_biome_pixel_color = water_image_data[Vector2(x, y)] #img.get_pixel(x, y)
			
			# Skip if the pixel is part of a region we've already processed or it's not a lake
			if processed_regions.has(water_biome_pixel_color) or water_biome_pixel_color == Color.BLACK:
				continue
			
			# Use flood fill to collect all pixels belonging to the current lake (region)
			var region_pixels = _flood_fill_collect_region(water_image_data, x, y, water_biome_pixel_color)
			
			# Calculate the average height for the region
			var total_height = 0.0
			for pixel in region_pixels:
				total_height += heightmap_image_data[Vector2(pixel.x, pixel.y)].r  # Assuming heightmap stores height in red channel
			
			var average_height = total_height / region_pixels.size()
			
			# Assign the average height to all the region's pixels in the output image
			for pixel in region_pixels:
				output_image_data[Vector2(pixel.x, pixel.y)] = Color(average_height, average_height, average_height)
				
			
			# Mark this region as processed
			processed_regions[water_biome_pixel_color] = true
	
	
	return output_image_data

# Flood fill function to collect all pixels of a region
func _flood_fill_collect_region(image_data: Dictionary, start_x: int, start_y: int, region_color: Color) -> Array:
	
	var pixels = []
	var stack = []
	stack.append(Vector2(start_x, start_y))
	
	var width = sqrt(len(image_data))
	var height = width
	
	while stack.size() > 0:
		var current = stack.pop_back()
		var x = int(current.x)
		var y = int(current.y)
		
		if image_data[Vector2(x, y)] == region_color:
			pixels.append(Vector2(x, y))
			image_data[Vector2(x, y)] = Color.BLACK  # Mark as visited by changing the color
			
			# Add neighboring pixels to the stack
			if x > 0: stack.append(Vector2(x - 1, y))
			if x < width - 1: stack.append(Vector2(x + 1, y))
			if y > 0: stack.append(Vector2(x, y - 1))
			if y < height - 1: stack.append(Vector2(x, y + 1))
	
	return pixels

func save_image_data(image_data: Dictionary):
	var output_images = []
	var grid_size = sqrt(len(water_biome_masks._images))
	var width = water_biome_masks._images[0].get_width()
	var height = water_biome_masks._images[0].get_height()
	
	#Save each image tile
	for i in range(len(water_biome_masks._images)):
		var new_image = Image.new()
		
		var img = water_biome_masks._images[i]
		#Copy config data from first image (height and width)
		new_image.copy_from(img)
		
		var coord_x = int(i / grid_size)
		var coord_y = i % int(grid_size)
		
		for y in range(height):
			for x in range(width):
				
				var img_data_x = coord_x * width + x
				var img_data_y = coord_y * height + y
				
				#Get the coordinate for the image data array
				var image_data_coord = Vector2(img_data_x, img_data_y)
				var pixel_color = image_data[image_data_coord]
				
				#set image pixel to image data color:
				new_image.set_pixel(x, y, pixel_color)
				
		output_images.append(new_image)

		
	var images_array = Texture2DArray.new()
	images_array.create_from_images(output_images)
	ResourceSaver.save(images_array, "res://Images/WaterBiomesWithAltitude.tres")
	print("Saved WaterBiomeLevels.tres")

# Call the function to start processing
func _ready():
	water_biome_masks = load("res://Images/WaterBiomeUniqueColors.tres")
	heightmaps = load("res://Images/LandmassesWithFaultlineDetail.tres")

	main()
