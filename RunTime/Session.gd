class_name Session
#This class is a save state, meant to hold data between game sessions
#nodes edit the variables here while running
#keeps track of scheduler threads

var Name: String = "Bot"
var Variables: Dictionary[String, BotVariable] = {}

var ActiveThreads: Array[BotThread]
var ThreadsToRemove: Array[BotThread]
var ThreadsToAdd: Array[BotThread]
