extends Node

var extra_thread = []
var mutex


func _ready():
	for i in range(0, OS.get_processor_count()-1):
		extra_thread.append(Thread.new())

	mutex = Mutex.new()
func Merge_Sort_GD(var a, var p, var r):
	if p < r:
		var q = (p+r)/2
		Merge_Sort_GD(a, p, q)
		Merge_Sort_GD(a, q+1, r)
		Merge(a, p, q, r)

func Merge_Sort_GD_Parse(var args: Array):
	mutex.lock()
	if(extra_thread.size() > 0):
		mutex.unlock()
		Merge_Sort_Threaded(args[0], args[1], args[2])
	else:
		mutex.unlock()
		Merge_Sort_GD(args[0], args[1], args[2])

func Merge_Sort_Threaded(var a, var p, var r):
	if p < r:
		mutex.lock()
		var left_thread = extra_thread.pop_back()
		var right_thread
		if(extra_thread.size() > 0):
			right_thread = extra_thread.pop_back()
		mutex.unlock()
		var q = (p+r)/2
		left_thread.start(self, "Merge_Sort_GD_Parse", [a, p, q])
		if right_thread != null:
			right_thread.start(self, "Merge_Sort_GD_Parse", [a, q+1, r])
			right_thread.wait_to_finish()
			mutex.lock()
			extra_thread.append(right_thread)
			mutex.unlock()
		else:
			Merge_Sort_GD(a, q+1, r)
		left_thread.wait_to_finish()
		Merge(a, p, q, r)
		mutex.lock()
		extra_thread.append(left_thread)
		mutex.unlock()

static func Merge(var a: Array, var p, var q, var r):
	var n1 = q-p+1
	var n2 = r-q

	#As we know the size the arrays need to be, this speeds up the operation
	#over appends.  I have observed >15% improvements to speed over appending
	#empty arrays.
	var left = []
	left.resize(n1+1)
	var right = []
	right.resize(n2+1)



	for i in range(n1):
		left[i] = a[p+i]
	for j in range(1, n2+1):
		right[j-1] = a[q+j]
	left[n1] = INF
	right[n2] = INF

	var i = 0
	var j = 0
	for k in range(p,r+1):
		if left[i] <= right[j]:
			a[k] = left[i]
			i +=1
		else:
			a[k] = right[j]
			j += 1

func is_sorted(array):
	var last = -INF
	for i in array:
		if last > i:
			print("FAILED SORTED TEST")
			return false
		last = i
	return true
