 #tool
extends Node2D

const CIVCOLORSHADER = preload("res://testpophead.shader")

# var mypalette = PoolColorArray()
# var image_from_code = Image.new()

# func _process(delta):
# 	for N in get_children():
# 		if typeof(N) == typeof(Sprite):
# 			if randi() % 1000 == 1:
# 				var whichsprite = randi() % 180
# 				N.region_rect = Rect2(whichsprite % 9 * 50, whichsprite / 9 * 50, 50, 50)
# 	pass

func _ready():
	randomize()
	# Set color palette size
	# mypalette.resize(256)
	var image_from_code = readpcx("temp/popHeads-ORIG.pcx")
	# sprite from code only
	var sprite_from_code = Sprite.new()
	# Create texture from image
	var texture_from_image = ImageTexture.new()
	texture_from_image.create_from_image(image_from_code)
	# apply texture to Sprite
	sprite_from_code.texture = texture_from_image
	sprite_from_code.apply_scale(Vector2(2, 2))
	# add shader
	var throwsomeshade = ShaderMaterial.new()
	throwsomeshade.shader = CIVCOLORSHADER
	sprite_from_code.material = throwsomeshade
	# vframes and hframes and region don't get along, and at least popheads has extra pixels
	# sprite_from_code.hframes = sprite_from_code.texture.get_width() / 50
	# sprite_from_code.vframes = sprite_from_code.texture.get_height() / 50
	for i in range(24):
		sprite_from_code.region_enabled = true
		var whichsprite = randi() % 180
		sprite_from_code.region_rect = Rect2(whichsprite % 9 * 50, whichsprite / 9 * 50, 50, 50)
		# sprite_from_code.frame = i + 1
		sprite_from_code.position.x = i % 8 * 120 + 70
		sprite_from_code.position.y = i * 20 + 70
		# sprite_from_code.centered = false
		# add sprite to scene
		print(sprite_from_code.vframes)
		print(sprite_from_code.hframes)
		add_child(sprite_from_code)
		sprite_from_code = sprite_from_code.duplicate()
	pass

func readpcx(filename):
	# not a generalized pcx reader
	# assumes 8-bit image with 256-color 8-bit rgb palette
	var file = File.new()
	file.open(filename, file.READ)
#	file.open("xpgc.pcx", file.READ)
	# seek to margins
	file.seek(0x4)
	var leftmargin = file.get_16()
	var topmargin = file.get_16()
	var rightmargin = file.get_16()
	var bottommargin = file.get_16()
	var width = rightmargin - leftmargin
	var height = bottommargin - topmargin
	print(width)
	print(height)
	# seek to bytes per scanline; assuming 1 color plane
	file.seek(0x42)
	# this is always even, so last byte may be junk if image width is odd
	var bytesperline = file.get_16()
	print(bytesperline)
	var imagelength = bytesperline * height
	print(imagelength)
	# seek to palette, 256*3 bytes from end of file
	file.seek_end(-(256*3))
	var palettebytes = file.get_buffer(256*3)
	var palette = PoolColorArray()
	palette.resize(256)
	for i in range(256):
		palette[i] = Color(
			palettebytes[i * 3] * 256 * 256 * 256 +
			palettebytes[i * 3 + 1] * 256 * 256 +
			palettebytes[i * 3 + 2] * 256 +
			255
		)
	# set shadow and transprent color values
	# This isn't quite right
#	for i in range(16):
#		# Shadow colors
#		palette.set(255 - i, Color(0.0, 0.0, 0.0, i / 15.0))
#		# Smoke/fog colors
#		palette.set(224 + i, Color(1.0, 1.0, 1.0, i / 15.0))
	palette.set(254, Color(0x00000080))
	palette.set(255, Color(0x00000000))
	palette.set(253, Color(0xffffffff))
	# Attempt at changing hue on civ colors to preserve intensity
	var color
	for i in range(64):
		color = palette[i]
		if i < 16 or i % 2 == 0:
#			color.h = 0.05
			color.a = 0.1
			palette[i] = color
		

	# seek to image data; assuming RLE-encoded
	file.seek(0x80)
	var i = 0
	var b = 0
	var runlen = 0
	var imagebytes = PoolByteArray()
	while i < imagelength and not file.eof_reached():
		b = file.get_8()
		# see if first 2 bits are 1s
		if b & 0xc0 == 0xc0:
			runlen = b & 0x3f
			b = file.get_8()
			for j in range(runlen):
				imagebytes.append(b)
				i += 1
		else:
			imagebytes.append(b)
			i += 1
	file.close()
		
	# create/format image data
	var image_from_code = Image.new()
	image_from_code.create(width, height, false, image_from_code.FORMAT_RGBA8)
	image_from_code.lock()
	for x in range(image_from_code.get_width()):
		for y in range(image_from_code.get_height()):
			image_from_code.set_pixel(x,y, palette[imagebytes[y * bytesperline + x]])
	image_from_code.unlock()
	return image_from_code
