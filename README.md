# Script Tabs for Godot

Script Tabs for Godot is a small editor plugin that adds a custom script tab bar to the Godot script editor.

It allows you to keep opened scripts visible as tabs, similar to the workflow used in editors like Visual Studio Code.

## Features

- Shows opened scripts as tabs inside the Godot script editor.
- Switches between scripts by clicking a tab.
- Closes script tabs using the close button.
- Supports keyboard navigation:
  - `Ctrl + Tab`: next script tab
  - `Ctrl + Shift + Tab`: previous script tab

## Installation

Copy the addon folder into your Godot project:

```text
addons/script_tabs/
```

Your project should look like this:

```text
your_project/
  addons/
    script_tabs/
      plugin.cfg
      script_tabs_plugin.gd
```

Then enable the plugin in Godot:

```text
Project > Project Settings > Plugins > Script Tabs > Enable
```

## Usage

Open scripts from the FileSystem or from the script list.

Every opened script will appear in the custom script tab bar. Click a tab to switch to that script, or click the close button to remove it from the tab bar.

## Keyboard Shortcuts

```text
Ctrl + Tab
```

Switches to the next opened script tab.

```text
Ctrl + Shift + Tab
```

Switches to the previous opened script tab.

## Compatibility

Tested with Godot 4.6.3.

## License

This project is licensed under the MIT License.
