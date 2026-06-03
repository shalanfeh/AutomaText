#global
extends Node

var HomeShowing: bool = true

signal CloseAllPopUps
signal CreateSequenceTab(SeqName: String)
signal OpenHomeScreen
signal TabSelected(SeqName: String)
signal TabClosed(NewTab: String)
signal DraggingVariable(VarName: String)
signal NoLongerDraggingVariable()
