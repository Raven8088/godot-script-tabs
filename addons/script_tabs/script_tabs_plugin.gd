@tool
extends EditorPlugin

var top_bar: HBoxContainer
var tab_bar: TabBar
var opened_scripts: Array[Script] = []
var closed_paths := {}
var last_current_script_path := ""
var is_switching_script := false


func _enter_tree() -> void:
	set_process_unhandled_key_input(true)

	top_bar = HBoxContainer.new()
	top_bar.name = "ScriptTabsTopBar"
	top_bar.custom_minimum_size = Vector2(600, 30)
	top_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var label := Label.new()
	label.text = "Scripts:"
	label.custom_minimum_size = Vector2(55, 24)

	tab_bar = TabBar.new()
	tab_bar.name = "Scripts"
	tab_bar.custom_minimum_size = Vector2(550, 28)
	tab_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# I show the close button on every tab.
	tab_bar.tab_close_display_policy = TabBar.CLOSE_BUTTON_SHOW_ALWAYS

	tab_bar.tab_changed.connect(_on_tab_changed)
	tab_bar.tab_close_pressed.connect(_on_tab_close_pressed)

	top_bar.add_child(label)
	top_bar.add_child(tab_bar)

	var script_editor := get_editor_interface().get_script_editor()
	if script_editor:
		_remove_old_script_tabs(script_editor)

		var main_vbox := _find_main_script_editor_vbox(script_editor)
		if main_vbox:
			main_vbox.add_child(top_bar)
			main_vbox.move_child(top_bar, 1)
		else:
			push_warning("Script Tabs: main script editor VBoxContainer was not found.")

	print("Script Tabs addon loaded")


func _exit_tree() -> void:
	set_process_unhandled_key_input(false)

	if top_bar:
		top_bar.queue_free()

	opened_scripts.clear()
	closed_paths.clear()


func _process(_delta: float) -> void:
	if is_switching_script:
		return

	_sync_current_script()


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	if not event.pressed or event.echo:
		return

	if event.ctrl_pressed and event.keycode == KEY_TAB:
		if event.shift_pressed:
			_select_previous_tab()
		else:
			_select_next_tab()

		get_viewport().set_input_as_handled()


func _sync_current_script() -> void:
	var script_editor := get_editor_interface().get_script_editor()
	if script_editor == null:
		return

	var current_script := script_editor.get_current_script()
	if current_script == null:
		return

	var current_path := current_script.resource_path

	if current_path != last_current_script_path:
		closed_paths.erase(current_path)
		last_current_script_path = current_path

	if closed_paths.has(current_path):
		return

	if not opened_scripts.has(current_script):
		opened_scripts.append(current_script)
		tab_bar.add_tab(current_script.resource_path.get_file())

	var index := opened_scripts.find(current_script)
	if index != -1 and tab_bar.current_tab != index:
		tab_bar.current_tab = index


func _on_tab_changed(tab_index: int) -> void:
	if tab_index < 0 or tab_index >= opened_scripts.size():
		return

	var script := opened_scripts[tab_index]
	if script == null:
		return

	is_switching_script = true
	closed_paths.erase(script.resource_path)
	get_editor_interface().edit_resource(script)
	is_switching_script = false


func _on_tab_close_pressed(tab_index: int) -> void:
	if tab_index < 0 or tab_index >= opened_scripts.size():
		return

	var closed_script := opened_scripts[tab_index]
	var was_current := tab_bar.current_tab == tab_index

	if closed_script:
		closed_paths[closed_script.resource_path] = true

	opened_scripts.remove_at(tab_index)
	tab_bar.remove_tab(tab_index)

	if opened_scripts.is_empty():
		return

	if was_current:
		var next_index := tab_index

		if next_index >= opened_scripts.size():
			next_index = opened_scripts.size() - 1

		tab_bar.current_tab = next_index
		_on_tab_changed(next_index)
	else:
		var current_index := clamp(tab_bar.current_tab, 0, opened_scripts.size() - 1)
		tab_bar.current_tab = current_index


func _select_next_tab() -> void:
	if opened_scripts.is_empty():
		return

	var next_index := tab_bar.current_tab + 1

	if next_index >= opened_scripts.size():
		next_index = 0

	tab_bar.current_tab = next_index
	_on_tab_changed(next_index)


func _select_previous_tab() -> void:
	if opened_scripts.is_empty():
		return

	var previous_index := tab_bar.current_tab - 1

	if previous_index < 0:
		previous_index = opened_scripts.size() - 1

	tab_bar.current_tab = previous_index
	_on_tab_changed(previous_index)


func _find_main_script_editor_vbox(script_editor: Node) -> VBoxContainer:
	for child in script_editor.get_children():
		if child is VBoxContainer:
			return child

	return null


func _remove_old_script_tabs(root: Node) -> void:
	for child in root.get_children():
		if child.name == "ScriptTabsTopBar":
			child.queue_free()
			continue

		_remove_old_script_tabs(child)
