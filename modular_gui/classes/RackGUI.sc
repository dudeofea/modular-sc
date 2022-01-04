RackGUI {
	var window, modules, server;

    *new { |window, server|
		var obj = super.newCopyArgs(window, List.new, server);
        window.front;
		window.onClose = { obj.free(); };
		^obj;
    }

	addModule { |name, synth_fn, gui_fn|
		modules.add(RackModule.new(window, server, name, synth_fn, gui_fn));
	}

	free {
		modules.do({ arg item, i; item.free; });
	}
}

RackModule {
	var <view, name, synth, enabled;

	*new { |parent, server, name, synth_fn, gui_fn|
		var new_view, new_synth, msg, obj;

		new_view = CompositeView.new(parent, Rect(2, 2, 100, 600));
		new_view.background = Color.red;

		new_synth = Synth.basicNew(name, server);
		SynthDef(name, { |out, volume = 0.0|
			Out.ar(out, volume * SynthDef.wrap(synth_fn));
		}).add(completionMsg: new_synth.newMsg);

		obj = super.newCopyArgs(new_view, name, new_synth);
		obj.init(gui_fn);
		^obj;
	}

	init { |gui_fn|
		var on_button;

		on_button = Button(view, Rect(10, 10, 80, 20));
		on_button.states = [
			["Off", Color.black, Color.red],
			["On", Color.black, Color.green]
		];
		on_button.action = {
			arg synth, button;
			if(button.value == 0, {
				synth.set(\volume, 0.0);
			}, {
				synth.set(\volume, 1.0);
			});
		}.value(synth, _);

		gui_fn.value(view, synth);
	}

	free {
		("Freeing Module" + name).postln;
		view.free;
		synth.free;
	}
}