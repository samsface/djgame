@tool
extends Control
class_name UVPack

#https://forum.godotengine.org/t/how-to-unwrap-uv2-for-lightmap-ao-from-gdscript/22199/2

@export var refresh: bool: set = set_refresh

func set_refresh(_newval):
	pack()
func _ready():
	pack()


var rects = []

static func builtin_unwrap(old_mesh, lightmap_texel_size = 0.01):
	var mesh = ArrayMesh.new()

	for surface_id in range(old_mesh.get_surface_count()):
		mesh.add_surface_from_arrays(
			Mesh.PRIMITIVE_TRIANGLES, 
			old_mesh.surface_get_arrays(surface_id)
		)
		var old_mat = old_mesh.surface_get_material(surface_id)
		mesh.surface_set_material(surface_id, old_mat)

	mesh.lightmap_unwrap(Transform3D.IDENTITY, lightmap_texel_size)
	#use_in_baked_light = true
	return mesh

func pack():
	rects = create_test_rects(40) #40 #2200
	rects.sort_custom(Callable(self, "sort_rect"))
	rects = pack_naive(rects)
	#var time = OS.get_system_time_msecs()
	var output = pack_optimal(rects)
	rects = output[0]
	#print(str("pack: ", OS.get_system_time_msecs() - time, " ms"))
	print(str(output[1], " - ", output[2]))
	render_rects(rects)
	render_rects(output[3], false)

func pack_naive(rects2):
	var x = 0
	var y = 0
	for i in range(rects2.size()):
		var rect = rects2[i]
		rects2[i] = Rect2(x, y, rect.size.x, rect.size.y)
		x += rect.size.x
	return rects2

func pack_optimal(rects2):
	var xmax = 0
	var ymax = 0
	var vslots = []
	var hslots = []
	var holes = []
	for i in range(rects2.size()):
		var rect = rects2[i]
		var sx = rect.size.x
		var sy = rect.size.y
		
		var pos = Vector2(0, 0)
		var bestinc = INF
		var best_v = -1
		var best_h = -1
		var bestslots = 0
		var beststart = 0
		#var bestremaining = 0
		
		#Does a fitting hole exist
		var hole_found = false
		for j in range(holes.size()):
			var hole = holes[j]
			if sx <= hole.size.x and sy <= hole.size.y:
				pos = hole.position
				rects2[i] = Rect2(pos, rect.size)
				hole_found = true
				
				var filled = false
				if hole.size.x - sx > 0:
					holes[j] = Rect2(pos + Vector2(sx, 0), hole.size - Vector2(sx, 0))
					filled = true
				if hole.size.y - sy > 0:
					if filled:
						holes.append(Rect2(pos + Vector2(0, sy), Vector2(sx, hole.size.y - sy)))
					else:
						holes[j] = Rect2(pos + Vector2(0, sy), hole.size - Vector2(0, sy))
						filled = true
				if !filled:
					holes[j] = Rect2(pos, Vector2.ZERO)
				
				break
		if hole_found:
			continue
		
		for j in vslots.size():
			var slot = vslots[j]
			var slotinc = max(slot.x + sx, slot.y + sy)
			if slotinc < bestinc:
				var new_bestinc = slotinc
				var new_best_height = slot.x + sx
				var new_bestslots = 1
				var new_beststart = slot.x
				var remaining = sy - slot.z
				while remaining > 0 and vslots.size() > j + new_bestslots:
					var nextslot = vslots[j + new_bestslots]
					remaining -= nextslot.z
					if nextslot.x + sx > new_best_height:
						new_bestinc = max(nextslot.x + sx, slot.y + sy)
						new_best_height = nextslot.x + sx
						new_beststart = nextslot.x
					new_bestslots += 1
				if new_bestinc < bestinc:
					bestinc = new_bestinc
					best_v = j
					bestslots = new_bestslots
					beststart = new_beststart
		
		for j in hslots.size():
			var slot = hslots[j]
			var slotinc = max(slot.x + sx, slot.y + sy)
			if slotinc < bestinc:
				var new_bestinc = slotinc
				var new_best_height = slot.y + sy
				var new_bestslots = 1
				var new_beststart = slot.y
				var remaining = sx - slot.z
				while remaining > 0 and hslots.size() > j + new_bestslots:
					var nextslot = hslots[j + new_bestslots]
					remaining -= nextslot.z
					if nextslot.y + sy > new_best_height:
						new_bestinc = max(slot.x + sx, nextslot.y + sy)
						new_best_height = nextslot.y + sy
						new_beststart = nextslot.y
					new_bestslots += 1
				if new_bestinc < bestinc:
					bestinc = new_bestinc
					best_h = j
					bestslots = new_bestslots
					beststart = new_beststart
		
		#try endpoints
		"""
		if hslots.size() > 0:
			var slot = hslots[hslots.size()-1]
			var h = 0
			if vslots.size() > 0:
				var slot2 = vslots[vslots.size()-1]
				h = slot2.y + slot2.z
			var start = Vector2(slot.x + slot.z, h)
			var slotinc = max(start.x + sx, start.y + sy)
			if slotinc < bestinc:
				var new_bestinc = slotinc
				pos = start
				best_v = -1
				best_h = -1
				
		if vslots.size() > 0:
			var slot = vslots[vslots.size()-1]
			var h = 0
			if hslots.size() > 0:
				var slot2 = hslots[hslots.size()-1]
				h = slot2.x + slot2.z
			var start = Vector2(h, slot.y + slot.z)
			var slotinc = max(start.x + sx, start.y + sy)
			if slotinc < bestinc:
				var new_bestinc = slotinc
				pos = start
				best_v = -1
				best_h = -1
		"""
		
		
		
		"""
		if i == 40:
			print(best_h)
			#print(str("vslots:",vslots))
			print(str("hslots:",hslots))
			print(beststart)
		"""
		#if i == 20:
		#	break
		
		if best_h >= 0:
			var slot = hslots[best_h]
			pos = Vector2(slot.x, beststart)
			
			#add holes
			for k in range(best_h, best_h + bestslots):
				var slot2 = hslots[k]
				if slot2.y < beststart:
					holes.append(Rect2(slot2.x, slot2.y, min(slot2.z, slot.x + sx - slot2.x), beststart - slot2.y))
			
			var new_hslots = []		
			#add array start
			for k in range(0, best_h):
				new_hslots.append(hslots[k])
			#add middle
			new_hslots.append(Vector3(slot.x, beststart+sy, sx))
			var last_slot = hslots[best_h + bestslots - 1]
			var endpoint = slot.x + sx
			if last_slot.x + last_slot.z > endpoint:
				new_hslots.append(Vector3(endpoint, last_slot.y, last_slot.x + last_slot.z - endpoint))
			#add array end
			for k in range(best_h + bestslots, hslots.size()):
				new_hslots.append(hslots[k])
			hslots = new_hslots
			
			#add vslot if new height is exceeding the last slot end pos in other direction
			var lastv = vslots[vslots.size()-1]
			if lastv.x < slot.x + sx:	
				vslots.append(Vector3(pos.x + sx, beststart,sy))		
		elif best_v >= 0:
			var slot = vslots[best_v]
			pos = Vector2(beststart, slot.y)
			
			#add holes
			for k in range(best_v, best_v + bestslots):
				var slot2 = vslots[k]
				if slot2.x < beststart:
					holes.append(Rect2(slot2.x, slot2.y, beststart - slot2.x, min(slot2.z, slot.y + sy - slot2.y)))
			
			var new_vslots = []	
			#add array start
			for k in range(0, best_v):
				new_vslots.append(vslots[k])
			#add middle
			new_vslots.append(Vector3(beststart+sx, slot.y, sy))
			var last_slot = vslots[best_v + bestslots - 1]
			var endpoint = slot.y + sy
			if last_slot.y + last_slot.z > endpoint:
				new_vslots.append(Vector3(last_slot.x, endpoint, last_slot.y + last_slot.z - endpoint))
			#add array end
			for k in range(best_v + bestslots, vslots.size()):
				new_vslots.append(vslots[k])
			vslots = new_vslots
			
			#add hslot if new height is exceeding the last slot end pos in other direction
			var lasth = hslots[hslots.size()-1]
			if lasth.y < slot.y + sy:
				hslots.append(Vector3(beststart, pos.y + sy, sx))
		else:
			#Add first or endpoint rectangle (neither of them have a slot
			vslots.append(Vector3(sx, pos.y, sy))
			hslots.append(Vector3(pos.x, sy, sx))
		
		if xmax < pos.x + sx: xmax = pos.x + sx
		if ymax < pos.y + sy: ymax = pos.y + sy
		
		rects2[i] = Rect2(pos, rect.size)
	return [rects2, xmax, ymax, holes]

func create_test_rects(count):
	var rects2 = []
	var rng = RandomNumberGenerator.new()
	for _i in range(count):
		var x = int(20 * rng.randf()) + 1
		var y = int(20 * rng.randf()) + 1
		rects2.append(Rect2(Vector2.ZERO, Vector2(x, y)))
	return rects2

static func sort_rect(a, b):
	return a.size.x + a.size.y > b.size.x + b.size.y

func render_rects(rects2, clean = true):
	if clean:
		for n in get_children():
			remove_child(n)
			n.free()
	for rect in rects2:
		var crect = ColorRect.new()
		add_child(crect)
		crect.position = rect.position
		crect.custom_minimum_size = rect.size
		var hue = 0
		if rect.size.y > 0: hue = (float(rect.size.x) / float(rect.size.y)) * 0.12
		var color = Color.from_hsv(hue - int(hue), 0.9, 0.9, 0.7)
		if !clean:
			color = Color.from_hsv(0.0, 0.0, hue - int(hue) + 0.5, 0.7)
		crect.modulate = color
		crect.set_owner(self)
		pass
