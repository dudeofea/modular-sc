Quarks.install(File.getcwd() +/+ "modular_gui");

(
~rack = RackGUI.new(Window("Modular Supercollider", Window.availableBounds, scroll: true), s);
"./mod_simple_drone.scd".loadRelative;
)