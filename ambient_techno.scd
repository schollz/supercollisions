(
SynthDef(\pad0, {
	var snd;
	snd = Saw.ar(\freq.kr(440) * ((-3..3) * 0.05).midiratio * [1, 2, 1, 4, 1, 2, 1]);
	snd = RLPF.ar(snd, LFNoise2.kr(0.3 ! snd.size).linexp(-1, 1, 100, 8000), 0.3);
	snd = Splay.ar(snd);
	snd = snd * Env.asr(0.8, 1, 0.8).ar(Done.freeSelf, \gate.kr(1));
	snd = snd * -30.dbamp;
	Out.ar(\out.kr(0), snd);
}).add;

SynthDef(\pad1, {
	var snd;
	snd = Saw.ar(\freq.kr(440) * ((-3..3) * 0.05).midiratio * [1, 2, 1, 4, 1, 2, 1]);
	snd = Splay.ar(snd);
	snd = MoogFF.ar(snd, XLine.kr(100,rrand(6000,12000),8), 0);
	snd = snd * Env.asr(0.8, 1, 0.8).ar(Done.freeSelf, \gate.kr(1));
	snd = Balance2.ar(snd[0], snd[1], \pan.kr(0));
	snd = snd * -10.dbamp;
	Out.ar(\out.kr(0), snd);
}).add;

SynthDef(\pad2,{
	var snd;
	snd = CombC.ar(PinkNoise.ar * -10.dbamp, \freq.kr(440).reciprocal, \freq.kr(440).reciprocal, 2.0);
	snd = snd ! 2;
	snd = LeakDC.ar(snd);
	snd = snd * Env.asr(0.8, 1, 0.8).ar(Done.freeSelf, \gate.kr(1));
	snd = Balance2.ar(snd[0], snd[1], \pan.kr(0));
	snd = snd * -50.dbamp;
	Out.ar(\out.kr(0), snd);
}).add;

SynthDef(\padFx, {
	var snd, env;
	snd = In.ar(\in.kr(0), 2);
	snd = snd * -10.dbamp;
	snd = snd + (NHHall.ar(snd, 8, modDepth: 1) * -5.dbamp);
	snd = snd + PitchShift.ar(snd, 0.2, 0.5);
	snd = snd + PitchShift.ar(snd, 0.13, 0.2);
	snd = DelayC.ar(snd, 0.2, SinOsc.ar(0.3, [0, pi]).linlin(-1,1,0,0.001));
	env = Env.perc(0.2, 0.5, curve: -2).kr(Done.none, \gate.tr(0));
	snd = snd * (1 - (0.9 * env));
	snd = MoogFF.ar(snd, 9000 * (1 - (0.5 *env)) + 100, 0);
	snd = snd + NHHall.ar(snd, 2);
	snd = LPF.ar(snd, MouseY.kr(100,20000,1));
	ReplaceOut.ar(\out.kr(0), snd * 6.dbamp);
}).add;

)

(
~notes="
c4 e5 g5
e4 c5 a5
d4 f5 a5
a5 c4 f5
";
)

(
Routine {
	var bpm, beat;
	var s;
	var padBus, padGroup, padFx;
	s = Server.default;
	padBus = Bus.audio(s, 2);
	padGroup = Group();

	bpm = 60;
	beat = 60/bpm;

	padFx = Synth.tail(padGroup, \padFx, [in: padBus, out:0,  gate: 0]);
	s.sync;

	Routine {
		loop {
			~notes.split($\n).do { |line|
				var parts = line.postln.stripWhiteSpace.split($ );
				var notes=Array.new(parts.size);
				var synths=Array.new(parts.size*2);
				var j=0;
				if (parts[0].size > 0) {
					parts.do { |part,i|
						var note, octave;
						note="c#d#ef#g#a#b".indexOf(part[0]);
						octave=part[1].asString.asInteger;
						note=note+(12*octave);
						notes.insert(i,note);
					};
					notes.postln;
					j=0;
					notes.do { |note|
						s.makeBundle(s.latency, {
							synths.insert(j,Synth.head(padGroup,\pad1, [freq: note.midicps, out: padBus]));
							j=j+1;
							synths.insert(j,Synth.head(padGroup,\pad0, [freq: note.midicps, out: padBus]));
							j=j+1;
						});
					};
					(3.5*beat).wait;
					synths.do { |synth|
						s.makeBundle(s.latency,{
							synth.set(\gate,0);
						});
					};
					(0.5*beat).wait;
				};
			};
		};
	}.play;
}.play;
)
