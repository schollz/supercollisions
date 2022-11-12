(
SynthDef(\bass, { arg freq = 440, amp = 0.5, gate = 1;
	var snd, env, oscfreq, output;
	var lfo;
	oscfreq = {freq * LFNoise2.kr(Rand(0.0001,0.5)).range(0.98, 1.02)}!10;
	lfo = { SinOsc.kr({ 1/Rand(2,52) }!10) };
	env = Env.adsr(0.2, 1, 0.9,0.1).kr(doneAction:2, gate: gate);
	output = LFSaw.ar(oscfreq, mul: lfo.value.range(0,1));
	output = Fold.ar(output,-0.5,0.5);
	output = RLPF.ar(output, (env*freq*0.7) + (freq * lfo.value.range(0.1,2)), lfo.value.range(0.2,1));
	output = Splay.ar(output, lfo.value.range(0,1));
	output = output * env * amp;
	Out.ar(0, output);
}).add;
)
(
Pdef(\bass, Pbind(
	\instrument, \bass,
	\tempo, 180/60,
	\ctranspose, -30,
	\degree, Pseq([Pseq([3, 5, 1, 3, 5, 8, 1], 2), Pseq([3, 2, 5, -1], 1), Pseq([3, 2, 5, 0], 1), Pseq([1, 5, 0,1,2,5,4], 2), Pseq([1, 0,2],2), 3],inf),
	\dur, Pseq([Pseq([8, 4, 4, 8, 4, 2, 2], 2), Pseq([8,4,2, 2], 2),Pseq([8, 4, 4, 8, 4, 2, 2], 2), Pseq([8, 4, 4], 2), 16], inf),
	\legato, 1.0,
	\amp, 0.6,
)).play;

)
(
Pdef(\bass, Pmono(\bass,
	\tempo, 180/60,
	\ctranspose, -26,
	\degree, Pseq([Pseq([3, 5, 1, 3, 5, 8, 1], 2), Pseq([3, 2, 5, -1], 1), Pseq([3, 2, 5, 0], 1), Pseq([1, 5, 0,1,2,5,4], 2), Pseq([1, 0,2],2), 3],inf),
	\dur, Pseq([Pseq([8, 4, 4, 8, 4, 2, 2], 2), Pseq([8,4,2, 2], 2),Pseq([8, 4, 4, 8, 4, 2, 2], 2), Pseq([8, 4, 4], 2), 16], inf)/8,
	\legato, 1.0,
	\amp, 0.5
)).play;
)