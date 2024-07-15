extends Node2D
class_name  FuzzySearch

@export var data:Array

class FuzzySearchResult:
	var matches := {}

	func get_matches() -> Array:
		var matches_array = []

		for i in matches.values():
			matches_array.append(i)

		matches_array.sort()

		return matches_array

	func get_matches_as_substr_sequences() -> Array:
		var matches_array = get_matches()
		var match_seqs = []

		var i = 0
		while i < matches.size():
			var begin = i
			while i < matches.size() -1 and matches_array[i] + 1 == matches_array[i+1]:
				i += 1
			
			match_seqs.append(matches_array[begin])
			match_seqs.append(matches_array[i] - matches_array[begin] + 1)
			
			i += 1
	
		return match_seqs

func decorate(input: String, positions: Array) -> String:
	if positions.is_empty():
		return input

	var result = ""
	var offset = 0  # Index to keep track of positions
	var i = 0
	
	while i < positions.size():
		result += input.substr(offset, positions[i] - offset)

		result += "[color=blue]"
		
		offset = positions[i]
		
		while i < positions.size() -1 and positions[i] + 1 == positions[i+1]:
			i += 1
		
		if offset == positions[i]:
			result += input[offset]
			offset += 1
		else:
			result += input.substr(offset, positions[i] - offset + 1)
			offset =  positions[i] + 1

		result += "[/color]"
		
		i += 1
	
	if positions.back() != input.length():
		result += input.substr(positions.back() + 1)

	return result


	
	#var x = score_fuzzy("ske", "skeleton")[0]
	#print(x < "big_enemy_killed.wav".length())



# 0 1 2 3
# 1 0 0 0 

# 0 1
# 1 0
# 2 0
# 3 0

func print_matrix(mat, str1, str2):
	
	var n = str1.length() + 1
	var m = str2.length() + 1
	
	var h = "    "
	for c in str2:
		h += c + " "
	print(h)
	
	for nn in n :
		var s = "  "
		if nn > 0:
			s = str1[nn-1] + " "
		
		for mm in m:
			s += str(mat[m * nn + mm]) + " "
		
		print(s)

	print()

# This is a Levenshtein distance approach with some agressive cleverish weighting inspired by the VSCode's fuzzy search.
# Its technique is optimized for searching files.
func score_fuzzy(str1: String, str2: String) -> Array:
	var allow_mistakes = true
	
	str1 = str1.to_lower()
	str2 = str2.to_lower()

	var len_str1 = str1.length()
	var len_str2 = str2.length()

	var n = len_str1 + 1
	var m = len_str2 + 1

	# Create a flat array to store the edit distances
	var dp = []
	# And another array to store the counts of sequneces that match
	var matches = []
	for i in range(n * m):
		dp.append(0)
		matches.append(0)
	
	var begin_idx = m + 1

	# Calculate the edit distances
	for i in range(1, n):
		for j in range(1, m):
			var current_idx = i * m + j
			var north_west_idx = current_idx - (m + 1)
			var west_idx = current_idx - 1
			
			var score = 0
			
			if dp[north_west_idx] == 0 and i > 1:
				score = 0
			elif str1[i - 1] == str2[j - 1]:
				
				score = 1
				
				
				if current_idx == begin_idx:
					score += 8
				
				matches[current_idx] = matches[north_west_idx] + 1
				
				score += matches[current_idx] * 5
				
			if (score or allow_mistakes) and (dp[north_west_idx] + score) >= dp[west_idx]:
				score = score + dp[north_west_idx]
			else:
				score = dp[west_idx]

			dp[current_idx] = score

	#print_matrix(dp, str1, str2)

	# The bottom-right cell of the matrix contains the Levenshtein distance
	var most_south_west_idx = len_str2 * (len_str1 + 1) + len_str1
	
	var positions = []
	var p = most_south_west_idx
	
	# Walk back through the matches and get all matched chars.
	# Useful for highlting match characters in search result UX.
	while p > 0:
		if matches[p] > 0:
			positions.push_front((p % m) - 1)
			p -= m
		
		p -= 1

	if allow_mistakes:
		if positions.size() < str1.length() - 1:
			return [0, []]

	return [dp[most_south_west_idx], tidy_positions(str2, positions)]


func tidy_positions(str, positions):
	return positions
	var positions_new := []
	
	for p in positions:
		var from = 0 if positions_new.is_empty() else positions_new.back() + 1
		
		for s in range(from, str.length()):
			if str[s] == str[p]:
				positions_new.append(s)
				break
				
	return positions_new




func score_fuzzy_path_(query:String, path:String):
	var split_path = path.split("/")
	var offset = 0
	
	var max = [0, []]

	for path_idx in split_path.size():
		var end_of_path = path_idx == split_path.size() -1
		
		var res = score_fuzzy(query, String(split_path[path_idx]) + ("" if end_of_path else "/"))

		if end_of_path:
			res[0] *= 100

		if res[0] > max[0]:
			max = res
			
			for i in res[1].size():
				res[1][i] = res[1][i] + offset

		offset += split_path[path_idx].length() + 1

	#print(max)

	return max

func score_fuzzy_path(query:String, path:String):
	var regex_pattern := " | /"
	
	var regex = RegEx.new()
	regex.compile("[^\\/\\s]+")
	
	var query_tokens:Array[RegExMatch] = regex.search_all(query)

	var r = [0, []]

	for token in query_tokens:
		var res = score_fuzzy_path_(token.strings[0], path)
		if res[0] > 0:
			r[0] += res[0]
			r[1] = mergeArrays(r[1], res[1])

	r[1].sort()

	return r

func mergeArrays(arr1: Array, arr2: Array) -> Array:
	var mergedArray = []

	# Add elements from the first array
	for item in arr1:
		if item not in mergedArray:
			mergedArray.append(item)

	# Add elements from the second array
	for item in arr2:
		if item not in mergedArray:
			mergedArray.append(item)

	return mergedArray

func search(text:String) -> Array:
	var scores = []

	var total_score = 0

	for i in data.size():
		var t = data[i]
		var sf = score_fuzzy_path(text, t)
		if sf[0] > 0:
			scores.push_back([t, sf[0], sf[1], i])
			total_score += sf[0]


	var res := []
	if not scores.is_empty():

		var mean_score = total_score / scores.size()

		scores.sort_custom(func(a,b): return a[1] > b[1])

		for s in scores:
			if s[1] >= mean_score:
				res.push_back([s[0], decorate(s[0], s[2]), s[3]])
				
	return res
