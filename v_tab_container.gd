tool
extends MarginContainer
class_name VTabContainer

var hbox: HBoxContainer
var tab_bar: VBoxContainer
var tab_container: TabContainer

func ref_vals():
	hbox = get_node_or_null("HBoxContainer")
	if hbox:
		tab_bar = hbox.get_node_or_null("TabBar")
		tab_container = hbox.get_node_or_null("TabContainer")

func _ready() -> void:
	ref_vals()

	if Engine.editor_hint:

		if not hbox:
			hbox = HBoxContainer.new()
			hbox.name = "HBoxContainer"
			add_child(hbox)
			hbox.owner = get_tree().edited_scene_root
			hbox.set_meta("_edit_lock_", true)

		if not tab_bar:
			tab_bar = VBoxContainer.new()
			tab_bar.name = "TabBar"
			hbox.add_child(tab_bar)
			tab_bar.owner = get_tree().edited_scene_root
			tab_bar.set_meta("_edit_lock_", true)

		if not tab_container:
			tab_container = InnerTabContainer.new()
			tab_container.name = "TabContainer"
			tab_container.size_flags_horizontal = SIZE_EXPAND_FILL
			hbox.add_child(tab_container)
			tab_container.owner = get_tree().edited_scene_root
			tab_container.set_meta("_edit_lock_", true)

		if not tab_container.is_connected("control_added", self, "_on_tab_added"):
			tab_container.connect("control_added", self, "_on_tab_added", [], CONNECT_PERSIST)


func add_tab_button():
	var lb = Label.new()
	lb.name = "Label"
	lb.set_meta("_edit_lock_", true)

	var btn = Button.new()
	btn.size_flags_vertical = SIZE_SHRINK_CENTER

	tab_bar.add_child(btn)
	btn.owner = get_tree().edited_scene_root
	btn.add_child(lb)
	lb.owner = get_tree().edited_scene_root

func rename_button(btn: Button, tab_name: String):
	btn.name = "Button%s" % tab_name
	var lb = btn.get_child(0)
	lb.text = tab_name
	lb.rect_size = lb.get_minimum_size()
	lb.rect_rotation = -90
	lb.rect_position.x = 4
	lb.rect_position.y = lb.rect_size.x + 4
	btn.rect_min_size = Vector2(lb.rect_size.y+8, lb.rect_size.x+8)
	btn.rect_size = btn.rect_min_size


func update():
	var tab_total = tab_container.get_child_count()
	var diff = tab_total - tab_bar.get_child_count()

	if diff > 0:
		for _i in range(diff):
			 add_tab_button()
	else:
		for i in range(tab_total, tab_total-diff):
			var btn = tab_bar.get_child(i)
			btn.queue_free()

	var j := 0
	while(j < tab_total):
		var tab: Control = tab_container.get_child(j)
		var btn: Button = tab_bar.get_child(j)
		rename_button(btn, tab.name)
		if not btn.is_connected("pressed", self, "_on_button_pressed"):
			btn.connect("pressed", self, "_on_button_pressed", [j], CONNECT_PERSIST)

		if not tab.is_connected("tree_exited", self, "_tab_tree_exited"):
			tab.connect("tree_exited", self, "_tab_tree_exited", [], CONNECT_PERSIST)

		if not tab.is_connected("renamed", self, "_tab_renamed"):
			tab.connect("renamed", self, "_tab_renamed", [], CONNECT_PERSIST)
		j += 1

func _on_tab_added():
	ref_vals()
	call_deferred("update")

func _tab_tree_exited():
	ref_vals()
	call_deferred("update")

func _tab_renamed():
	ref_vals()
	call_deferred("update")

func _on_button_pressed(idx: int) -> void:
	tab_container.current_tab = idx

class InnerTabContainer:
	tool
	extends TabContainer

	signal control_added

	func _init() -> void:
		tabs_visible = false

	func add_child(node: Node, legible_unique_name:=false):
		.add_child(node, legible_unique_name)
		if node is Control:
			emit_signal("control_added")
