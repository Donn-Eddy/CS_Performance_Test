extends Node

#merge sort scripts
onready var cs_ms = preload("res://merge_sort.cs").new()
onready var gd_ms = preload("res://merge_sort_gd.gd").new()

#This is the default array size
export var num = 32
#This tells the user the current array size
onready var array_size = get_node("HBoxContainer/Array/Input/LineEdit")

var array = []
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	$HBoxContainer/Array/Input/LineEdit.text = str(num)
	generate_array(array, int(array_size.text))

	#This is not called by default as the script never enters the scene tree.
	gd_ms._ready()



#Make a random array
func generate_array(var a: Array, var size):
	var buffer
	a.clear()
	for i in range(0,size):
		buffer = rng.randi_range(-2000000000,2000000000)
		array.append(buffer)
	$HBoxContainer/Array/Current/LineEdit.text = str(size)

#This is to check the algorith works. If this is false, the results are invalid.
func is_sorted(a):
	var last = -INF
	for i in a:
		if last > i:
			print("FAILED SORTED TEST")
			return false
		last = i
	return true

#"Generate" button, generates random array at user's request.
func _on_Button_pressed():
	generate_array(array, int(array_size.text))

#Run the benchmark on it's own thread so the UI can be updated.
onready var bench_thread = Thread.new()
func _on_Bench_Button_pressed():
	if !bench_thread.is_active():
		bench_thread.start(self, "run_bench", null)
	else:
		bench_thread.wait_to_finish()

#These are all used to update the user 
onready var progress_bar = get_node("HBoxContainer/Array/ProgressBar")
func run_bench(var blank = null):
	var control_results_full = []
	var gd_results_full = []
	var gd_threads_results_full = []
	var cs_results_full = []
	var iterations = 100
	var sizes = 15
	var done_time = 0
	var new_array

	var array_sizes = []
	
	var inc_val = 100.0 / (sizes * iterations * 4.0)
	progress_bar.step = inc_val

	print("Starting Bench")
	for j in range(sizes):
		var control_results = []
		var gd_results = []
		var gd_threads_results = []
		var cs_results = []
		var bench_array_size = pow(2, j)
		print("Array Size: " + String(bench_array_size))
		array_sizes.append(bench_array_size)
		for i in range(iterations):
			generate_array(array, bench_array_size)
			new_array = start_bench()
			new_array.sort()
			done_time = end_bench()
			control_results.append(done_time)
			progress_bar.value += inc_val

			generate_array(array, bench_array_size)
			new_array = start_bench()
			gd_ms.Merge_Sort_GD(new_array, 0, new_array.size()-1)
			done_time = end_bench()
			gd_results.append(done_time)
			progress_bar.value += inc_val

			generate_array(array, bench_array_size)
			new_array = start_bench()
			gd_ms.Merge_Sort_Threaded(new_array, 0, new_array.size()-1)
			done_time = end_bench()
			gd_threads_results.append(done_time)
			progress_bar.value += inc_val

			generate_array(array, bench_array_size)
			#var data
			done_time = cs_ms.start_bench(Array(array))
			#data = cs_ms.Merge_Sort(new_array, 0, new_array.size()-1)
			# done_time = end_bench()
			#new_array = Array(array)
			cs_results.append(done_time)
			progress_bar.value += inc_val

		control_results_full.append(control_results)
		gd_results_full.append(gd_results)
		gd_threads_results_full.append(gd_threads_results)
		cs_results_full.append(cs_results)

	#I should make this it's own method... Oh well.
	#Prepares the .csv file.
	var file_string = "Test_Name"
	for i in range(1, iterations+1):
		file_string += ",Run " + String(i)
	file_string += "\nControl:"
	for i in range(0,control_results_full.size()):
		file_string += "\n" + String(array_sizes[i])
		for control_result in control_results_full[i]:
			file_string += "," + String(control_result)
	file_string += "\nGD_Script:"
	for i in range(0,gd_results_full.size()):
		file_string += "\n" + String(array_sizes[i])
		for gd_result in gd_results_full[i]:
			file_string += "," + String(gd_result)
	file_string += "\nGD_Script_Threaded:"
	for i in range(0,gd_threads_results_full.size()):
		file_string += "\n" + String(array_sizes[i])
		for gd_threaded_result in gd_threads_results_full[i]:
			file_string += "," + String(gd_threaded_result)
	file_string += "\nCS:"
	for i in range(0,cs_results_full.size()):
		file_string += "\n" + String(array_sizes[i])
		for cs_result in cs_results_full[i]:
			file_string += "," + String(cs_result)

	var file = File.new()
	if file.open("user://Results.csv", File.WRITE) != 0:
		print("Error opening file")
		return
	
	file.store_line(file_string)
	print(file.get_path())
	file.close()


#For benchmarking
var _start_time
func start_bench():
	var new_array = Array(array)
	_start_time = OS.get_ticks_usec()
	return new_array

func end_bench():
	return OS.get_ticks_usec() - _start_time


#For individual button presses, also runs test to ensure algorithm is functional.
#I used these for debugging purposes.
func _on_GDScriptButton_pressed():
	var new_array = Array(array)
	var start_time = OS.get_ticks_usec()
	gd_ms.Merge_Sort_GD(new_array, 0, new_array.size()-1)
	var end_time = OS.get_ticks_usec()
	is_sorted(new_array)
	
	$HBoxContainer/GDScript/LineEdit.text = str(end_time-start_time)

func _on_CSButton_pressed():
	var new_array = Array(array)
	var start_time = OS.get_ticks_usec()
	new_array = Array(cs_ms.Merge_Sort(new_array, 0, new_array.size()-1))
	var end_time = OS.get_ticks_usec()
	is_sorted(new_array)
	
	$HBoxContainer/CS/LineEdit.text = str(end_time-start_time)

func _on_GDScriptPButton_pressed():
	var new_array = Array(array)
	var start_time = OS.get_ticks_usec()
	gd_ms.Merge_Sort_Threaded(new_array, 0, new_array.size()-1)
	var end_time = OS.get_ticks_usec()
	is_sorted(new_array)

	$HBoxContainer/GDScriptP/LineEdit.text = str(end_time-start_time)

func _on_GDBaseButton_pressed():
	var new_array = Array(array)
	var start_time = OS.get_ticks_usec()
	new_array.sort()
	var end_time = OS.get_ticks_usec()
	is_sorted(new_array)
	
	$HBoxContainer/GodotBase/LineEdit.text = str(end_time-start_time)
