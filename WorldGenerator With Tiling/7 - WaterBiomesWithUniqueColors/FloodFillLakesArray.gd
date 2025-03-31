extends WorldGenProcess

var wc = WorldConfiguration.new()
var tile_count = wc.tile_count
var lake_masks: Texture2DArray

# Output image to store the result with unique colors for each lake
var output_image: Image

# Keep track of previously used colors to ensure uniqueness
var used_colors = []
var current_tile = Vector2.ZERO
var edge_pixels = {}


func main():
	
	var image_data = create_image_data()
	
	image_data = set_unique_colors(image_data)
	
	save_image_data(image_data)
	
	emit_signal("process_complete")
	pass

# Function to generate a random color, ensuring it's unique
func _generate_random_color() -> Color:
	var new_color: Color
	var is_unique: bool = false
	
	while not is_unique:
		# Generate a random color
		new_color = Color(randf(), randf(), randf())
		
		# Assume the color is unique until proven otherwise
		is_unique = true
		
		# Check if the color has already been used
		for color in used_colors:
			if color == new_color:
				is_unique = false
				break
	
	# If unique, add to the used_colors and return
	used_colors.append(new_color)
	return new_color

func create_image_data():
	#Take images from array and make array out of all the data
	var image_data = {}
	var grid_size = sqrt(len(lake_masks._images))
	
	#Extract height and width from first image (theyre all the same)
	var width = lake_masks._images[0].get_width()
	var height = lake_masks._images[0].get_height()
	
	for i in range(len(lake_masks._images)):
		#For each image, loop through width and height
		var img = lake_masks._images[i]

		var coord_x = int(i / grid_size)
		var coord_y = i % int(grid_size)
		
		#Construct Image Data
		for y in range(height):
			for x in range(width):
				var img_data_x = coord_x * width + x
				var img_data_y = coord_y * height + y
				
				#Get color from original image
				var pixel_color = img.get_pixel(x, y)
				image_data[Vector2(img_data_x, img_data_y)] = pixel_color
	
	return image_data

func set_unique_colors(image_data):
	var width = lake_masks._images[0].get_width()
	var height = lake_masks._images[0].get_height()
	
	#Loop through image data and perform flood fill.
	var img_data_width = width * sqrt(len(lake_masks._images))
	var img_data_height = height * sqrt(len(lake_masks._images))
	
	# Keep track of processed regions
	var visited_pixels = {}

	for y in range(img_data_height):
		for x in range(img_data_width):
			
			var pixel_color  = image_data[Vector2(x, y)]
			pixel_color = Vector3(pixel_color.r, pixel_color.g, pixel_color.b)
			
			# Check if the pixel is part of a lake (white) and hasn't been visited yet
			if pixel_color > Vector3(0,0,0) and not visited_pixels.has(Vector2(x, y)):
				var random_color = _generate_random_color()
				
				# Perform flood fill to color the entire connected region (lake)
				image_data = flood_fill_region(image_data, x, y, random_color, visited_pixels)
	
	return image_data
	
func flood_fill_region(image_data: Dictionary, start_x: int, start_y: int, fill_color: Color, visited_pixels: Dictionary):
	var stack = []
	stack.append(Vector2(start_x, start_y))
	
	var width = sqrt(len(image_data))
	var height = width
	
	while stack.size() > 0:
		var current = stack.pop_back()
		var x = int(current.x)
		var y = int(current.y)
		
		var pixel_color = image_data[Vector2(x, y)]
		pixel_color = Vector3(pixel_color.r, pixel_color.g, pixel_color.b)
		
		# Skip if already visited or not part of the lake (black)
		if visited_pixels.has(Vector2(x, y)) or pixel_color == Vector3(0,0,0):
			continue
		
		# Mark pixel as visited
		visited_pixels[Vector2(x, y)] = true
		
		#Set color
		image_data[Vector2(x, y)] = fill_color
		
		# Add neighboring pixels to the stack (4-connectivity)
		if x > 0: stack.append(Vector2(x - 1, y))
		if x < width - 1: stack.append(Vector2(x + 1, y))
		if y > 0: stack.append(Vector2(x, y - 1))
		if y < height - 1: stack.append(Vector2(x, y + 1))
		
	return image_data

func save_image_data(image_data):
	var output_images = []
	var grid_size = sqrt(len(lake_masks._images))
	var width = lake_masks._images[0].get_width()
	var height = lake_masks._images[0].get_height()
	#Save each image tile
	for i in range(len(lake_masks._images)):
		var new_image = Image.new()
		
		var img = lake_masks._images[i]
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
				
		#new_image.save_png("res://Images/%s.png" % i)
		output_images.append(new_image)
	var images_array = Texture2DArray.new()
	images_array.create_from_images(output_images)
	ResourceSaver.save(images_array, "res://Images/WaterBiomeUniqueColors.tres")
	print("Saved WaterBiomeUniqueColors.tres")

func _ready():
	lake_masks = load("res://Images/WaterBiomes.tres")
	main()

