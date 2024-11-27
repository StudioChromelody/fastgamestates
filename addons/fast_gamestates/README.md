# fastgamestates
With FastGameStates you can easily create menus, settings and gamestates within seconds! Use it for game jams or bigger projects. With this tool you don't have the struggle with loading and unloading menus anymore.

## Usage
1. Copy the plugin folder into your addons folder
2. Activate the plugin and reload your project
3. Create an empty startupscene (the type of the root node doesn't matter, but a simple "Node" type is recommended) and insert the name of the node into your FGS Settings tab
4. In the FGS Menus tab you can initialize new menus (Click Create new menu, set the settings at your liking and paste the path to the menu scene into the "Menu Scene Path" field). Go back to overview to save the menu
5. If you want to add a menu (e.g. main menu) at start up, simply add the name of your menu in the "Startup Menu" field of the FGS settings
6. To add your game, create a game controler (that handles all of your game) and paste the path to its scene in the "Gamecontroler" field. To load it on startup check the checkbox
7. In your main menu you can add a "StartButton" node which handles all of the scene changes automatically
8. To load a menu call `Gamestate.load_menu("menu_name")` from GDScript (the menus have to be created in the FGS Menus tab first)
9. To unload call `Gamestate.unload_menu()`
10. To add your own settings use `Gamestate.register_setting(...)`, `Gamestate.get_setting(...)`, `Gamestate.change_setting(...)` and `Gamestate.unregister_setting(...)`
11. To use shared values use `Gamestate.register_shared_value(...)`, `Gamestate.get_shared_value(...)`, `Gamestate.change_shared_value(...)` and `Gamestate.unregister_shared_value(...)`

## Currently available nodes
- StartButton ― Unloads the current menu and loads the game
- QuitButton ― Saves the game settings and quits the application
- ExitPauseButton ― Let's you exit a menu either by resuming the game or by going back to the main (startup) menu
- AudioSettingsHSlider ― An H-Slider that registers a setting and controls your audiobusses volume
- AudioSettingsCheckBox ― A checkbox that registers a setting and (Un-)mutes a specified audiobus (checked = unmute, unchecked = mute)
- RemapButton ― A button to remap your input mappings


For more information visit [our website](https://www.chromelody.com/godot/fastgamestates.html)