(
SynthDef("jp",{ | amp=1,freq = 523.3572, mix=0.75, detune = 0.75,lpf=10 |
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

	var center = Mix.new(LFSaw.ar(freq, Rand()));
	var detuneFactor = freq * detuneCurve.(detune);
	var freqs = [
		(freq - (detuneFactor * Rand(0.10,0.12))),
		(freq - (detuneFactor * Rand(0.05,0.07))),
		(freq - (detuneFactor * Rand(0.01,0.03))),
		// (freq + (detuneFactor * 0)),
		(freq + (detuneFactor * Rand(0.01,0.03))),
		(freq + (detuneFactor * Rand(0.05,0.07))),
		(freq + (detuneFactor * Rand(0.09,0.11)))
	];
	var side = Array.fill(6, { |n|
		Saw.ar(freqs[n], Rand(0, 2))
	});


	var sig = Splay.ar(side);
	sig = BLowPass.ar(sig,600,0.5);
	Out.ar(0,sig*amp);
}).add;
)

Synth("jp",[\freq,50,\mix,1,\detune,0.6])