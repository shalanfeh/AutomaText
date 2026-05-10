extends HSplitContainer
class_name UpperBar

@export_category("Child Nodes")
@export var TabHolder: TabBar
@export var HomeButton: TextureButton
@export var PlayButton: TextureButton

var ExistingTabs: Array[String] = []

func _ready() -> void:
	#home button
	HomeButton.pressed.connect(HomeClicked)
	
	#tab handling
	EventBus.CreateSequenceTab.connect(CreateTab)
	TabHolder.tab_close_pressed.connect(CloseTab)
	TabHolder.tab_changed.connect(TabSelected)
	TabHolder.tab_clicked.connect(TabSelected)
	
	#tab updating
	BotGlobal.SequenceRenamed.connect(TabRenamed)
	BotGlobal.SequenceRemoved.connect(TabRemoved)
	BotGlobal.Refresh.connect(OnRefresh)

func TabSelected(Idx: int) -> void:
	if Idx == -1:
		HomeClicked()
		return
	TabHolder.current_tab = Idx
	EventBus.TabSelected.emit(ExistingTabs[Idx])

func CreateTab(SeqName: String) -> void:
	#check if tab exists
	if ExistingTabs.has(SeqName):
		return
	
	#if it doesn't create it
	ExistingTabs.append(SeqName)
	TabHolder.add_tab(SeqName)

func CloseTab(idx: int) -> void:
	TabHolder.remove_tab(idx)
	ExistingTabs.remove_at(idx)
	
	if ExistingTabs.size() == 0:
		HomeClicked()
	else:
		EventBus.TabClosed.emit(ExistingTabs[TabHolder.current_tab])

#seq renamed
func TabRenamed(Target: String, NewName: String) -> void:
	#make sure it exists
	var idx: int = ExistingTabs.find(Target)
	if idx == -1:
		return
	
	#if it does, rename the tab
	ExistingTabs[idx] = NewName
	TabHolder.set_tab_title(idx, NewName)

#seq deleted
func TabRemoved(SeqName: String) -> void:
	#make sure it exists
	var idx: int = ExistingTabs.find(SeqName)
	if idx == -1:
		return
	
	ExistingTabs.erase(SeqName)
	TabHolder.remove_tab(idx)

func HomeClicked() -> void:
	if (EventBus.HomeShowing == true) and (TabHolder.current_tab != -1):
		EventBus.TabSelected.emit(ExistingTabs[TabHolder.current_tab])
		return
	EventBus.OpenHomeScreen.emit()

func OnRefresh() -> void:
	ExistingTabs.clear()
	TabHolder.clear_tabs()
	EventBus.OpenHomeScreen.emit()
