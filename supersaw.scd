
(
SynthDef("saw",{
	arg freq=220;
	var mix=MouseX.kr();
	var detune=MouseY.kr();
	var detuneCurve = { |x|
		(10028.7312891634*x.pow(11)) -
		(50818.8652045924*x.pow(10)) +
		(111363.4808729368*x.pow(9)) -
		(138150.6761080548*x.pow(8)) +
		(106649.6679158292*x.pow(7)) -
		(53046.9642751875*x.pow(6)) +
		(17019.9518580080*x.pow(5)) -
		(3425.0836591318*x.pow(4)) +
		(404.2703938388*x.pow(3)) -
		(24.1878824391*x.pow(2)) +
		(0.6717417634*x) +
		0.0030115596
	};
	var centerGain = { |x| (-0.55366 * x) + 0.99785 };
	var sideGain = { |x| (-0.73764 * x.pow(2)) + (1.2841 * x) + 0.044372 };

	var center = LFSaw.ar(freq, Rand());
	var freqs = [
		(freq - (freq*(detuneCurve.(detune))*0.11002313)),
		(freq - (freq*(detuneCurve.(detune))*0.06288439)),
		(freq - (freq*(detuneCurve.(detune))*0.01952356)),
	    //(freq + (freq*(detuneCurve.(detune))*0)),
		(freq + (freq*(detuneCurve.(detune))*0.01991221)),
		(freq + (freq*(detuneCurve.(detune))*0.06216538)),
		(freq + (freq*(detuneCurve.(detune))*0.10745242))
	];
	var side = Mix.fill(6, { |n|
		LFSaw.ar([freqs[n]*0.99,freqs[n]*1.005], Rand(0, 2))/6.0
	});

	var sig = (center * centerGain.(mix)) + (side * sideGain.(mix));

	sig = HPF.ar(sig, freq);
	sig = RLPF.ar(sig,MouseX.kr(10,18000,1),0.707);
	Out.ar(0,sig/4);
}).add;
)

(
Synth.new("saw",[\freq,24.midicps]);
Synth.new("saw",[\freq,60.midicps]);
)
