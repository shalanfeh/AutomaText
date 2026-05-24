extends Node
class_name Scheduler


var ActiveThreads: Array[BotThread]
var ThreadsToRemove: Array[BotThread]
var ThreadsToAdd: Array[BotThread]

#loops through active threads and calls run on them
func Run() -> void:
	for Target: BotThread in ActiveThreads:
		Target.Run()

#the trigger node is in charge of creating the thread.
#once the thread is created and initialized, it is added to the scheduler.

#adds a thread to threads to add
func AddThread(Target: BotThread) -> void:
	if ThreadsToAdd.has(Target):
		return
	ThreadsToAdd.append(Target)

#add a thread to thread to remove
func RemoveThread(Target: BotThread) -> void:
	if ThreadsToRemove.has(Target):
		return
	ThreadsToRemove.append(Target)

#goes through threads to add and adds them all
func AddTargetThreads() -> void:
	for Target: BotThread in ThreadsToAdd:
		if ActiveThreads.has(Target):
			continue
		ActiveThreads.append(Target)
	ThreadsToAdd.clear()

#goes through thread to remove and removes them all
func RemoveTargetThreads() -> void:
	for Target: BotThread in ThreadsToRemove:
		var TargetIDX: int = ActiveThreads.find(Target)
		if TargetIDX == -1:
			continue
		ActiveThreads.pop_at(TargetIDX)
	ThreadsToRemove.clear()

#repeatedly does this cycle while program is active
func DoCycle() -> void:
	if ActiveThreads.size() > 0:
		Run()
	
	if ThreadsToRemove.size() > 0:
		print("removed thread")
		RemoveTargetThreads()
	
	if ThreadsToAdd.size() > 0:
		print("added thread")
		AddTargetThreads()
