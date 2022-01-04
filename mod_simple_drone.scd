~rack.addModule(\SimpleDrone, {
	arg freq = 440;
	var h_freq, h_mul, h_type, h_sine, h_saw, h_pulse, type_filter;

	h_freq = NamedControl.kr(\harm_freq, Array.fill(5, 0));
	h_mul = NamedControl.kr(\harm_mul, [1.0] ++ Array.fill(4, 0));
	h_type = NamedControl.kr(\harm_type, Array.fill(5, 0.2));

	type_filter = { |val, arr|
		(1 - abs(val - arr).min(1));
	};
	h_sine = type_filter.value(0, h_type);
	h_saw = type_filter.value(1, h_type);
	h_pulse = type_filter.value(2, h_type);
	//[h_sine, h_saw, h_pulse].poll;

	Pan2.ar(
		Mix(Mix([
			SinOsc.ar(freq: freq * (1 + h_freq), mul: h_sine * h_mul * 0.2),
			Saw.ar(freq: freq * (1 + h_freq), mul: h_saw * h_mul * 0.2),
			Pulse.ar(freq: freq * (1 + h_freq), width: 0.3, mul: h_pulse * h_mul * 0.2)
		]))
	);
}, { |view, synth|
	var knob, envelope, slider;

	knob = Knob(view, Rect(10, 40, 80, 80));
	knob.value = 0.44;
	knob.background = Color.blue;
	knob.action = {
		arg synth, knob;
		synth.run;
		synth.set(\freq, knob.value * 1000);
	}.value(synth, _);

	envelope = EnvelopeView(view, Rect(10, 130, 80, 80));
    envelope.drawLines = true;
    envelope.selectionColor = Color.red;
    envelope.drawRects = true;
    envelope.resize = 5;
    envelope.thumbSize = 15;
    envelope.value = [
		[0.0, 0.25, 0.5, 0.75, 1.0],
		[1.0, 0.0, 0.0, 0.0, 0.0]
    ];
	envelope.setEditable(0, false);
	envelope.keepHorizontalOrder = true;
	envelope.action = {
		arg synth, e;
		var x, y;
		x = (e.value.at(0) * 15).floor;
		y = e.value.at(1) / [1, 5, 10, 15, 20];

		synth.set(\harm_freq, x);
		synth.set(\harm_mul, y);
		e.value = [x / 15, e.value.at(1)];
	}.value(synth, _);

	for(0, 5 - 1, { |i|
		var slider = Slider(view, Rect(10 + (15 * i), 220, 15, 80));
		slider.action = {
			arg synth, s;
			var new_val = s.value * 2;
			synth.getn(\harm_type, 5, { |vals|
				vals.put(i, new_val);
				synth.set(\harm_type, vals);
			});
		}.value(synth, _);
	});
});