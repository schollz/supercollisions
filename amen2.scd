

(
SynthDef(\slice,{
	var snd;
	snd = PlayBuf.ar(2,\buf.kr(0),BufRateScale.kr(\buf.kr(0)) * \rate.kr(1),
		startPos: BufFrames.kr(\buf.kr(0)) * \slice.kr(0) / \slices.kr(16));
	snd = snd * Env.linen(0, BufDur.kr(\buf.kr(0)) / \slices.kr(16), 0.01).ar;
	snd = snd * Env.asr(0.001, 1, 0.01).ar(Done.freeSelf, \gate.kr(1) * (1-TDelay.kr(Impulse.kr(0),\duration.kr(100000))) );
	snd = snd * -6.dbamp ! 2;
	snd = snd * EnvGen.ar(Env.new([1-\rampup.kr(0),1],[\duration.kr(100000)]),\rampup.kr(0));
	Out.ar(\out.kr(0),snd);
}).add;

SynthDef(\sliceStretch,{
	var rate = BufRateScale.ir(\buf.kr(0)) * \rate.kr(1);
	var startPos = BufFrames.kr(\buf.kr(0)) * \slice.kr(0) / \slices.kr(16);
	var pos = Phasor.ar(
		rate: rate / LinLin.kr((6.283185307*\stretch.kr(1)).sin,-1,1,2,10),
		start: startPos,
		end: BufFrames.ir(\buf.kr(0)),
		resetPos: startPos,
	);
	var window = Phasor.ar(
		rate: rate,
		start: pos,
		end: pos + (LinExp.kr((6.283185307*\stretch.kr(1)).cos,-1,1,0.01,1)*44100),
		resetPos: pos,
	);
	var snd = BufRd.ar(2, \buf.kr(0), window, loop:1, interpolation:4);
	snd = snd * Env.linen(0, BufDur.kr(\buf.kr(0)) / \slices.kr(16), 0.01).ar;
	snd = snd * Env.asr(0.001, 1, 0.01).ar(Done.freeSelf, \gate.kr(1) * (1-TDelay.kr(Impulse.kr(0),\duration.kr(100000))) );
	snd = snd * -6.dbamp ! 2;
	Out.ar(\out.kr(0),snd);
}).add;

SynthDef(\glitch,{
	var snd;
	snd = SinOsc.ar((SinOsc.ar(\modFreq.kr(3240)) * Env.perc(0.01,2).kr * \index.kr(3000) + \carrierFreq.kr(1000)).poll);
	snd = snd + PitchShift.ar(snd, Rand(0.03, 0.06), 2);
	snd = snd * Env.asr(0.001, 0.1, 0.01).ar(Done.freeSelf, \gate.kr(1) * (1-TDelay.kr(Impulse.kr(0),\duration.kr(100000))) );
	snd = snd * -6.dbamp ! 2;
	snd = Pan2.ar(snd, \pan.kr(0));
	Out.ar(\out.kr(0),snd);
}).add;

SynthDef(\bass,{
	arg freq=300;
	var snd;
	snd = SinOsc.ar(Env([freq,freq/3,freq/5].cpsmidi, [0.1,3], -4).ar.midicps * [-0.1, 0, 0.1].midiratio);
	snd = snd * Env.perc(0, 5).ar;
	snd = snd + (snd * 4).fold2;
	snd = RLPF.ar(snd, 3000 * (1 + Env.perc(0.3, 1).ar), 0.3);
	snd = snd + (snd * 3).fold2;
	snd = RLPF.ar(snd, 1000 * (1 + Env.perc(0.1, 1).ar), 0.3);
	snd = snd + (snd * 3).fold2;
	snd = snd * Env.perc(0.001, 3.0).ar(Done.freeSelf);
	snd = snd * -6.dbamp;
	snd = Splay.ar(snd,0.3);
	Out.ar(\out.kr(0),snd);
}).add;


SynthDef(\fx,{
	var snd;
	snd = In.ar(\in.kr(0), 2);
	snd = (snd * 30.dbamp).tanh * -10.dbamp;
	snd = SelectX.ar(\decimator.kr(1).lag(0.01), [snd, Latch.ar(snd, Impulse.ar(LFNoise2.kr(0.3).exprange(1000,16e3)))]);
	snd = SelectX.ar(\pitch1.kr(1).lag(0.01), [snd, PitchShift.ar(snd, 0.2, 2)]);
	snd = SelectX.ar(\pitch2.kr(1).lag(0.01), [snd, PitchShift.ar(snd, 0.03, 1.4)]);
	snd = BHiShelf.ar(BLowShelf.ar(snd, 500, 1, -10), 3000, 1, -10);
	snd = (snd * 10.dbamp).tanh * -10.dbamp;
	snd = BHiShelf.ar(BLowShelf.ar(snd, 500, 1, 10), 3000, 1, 10);
	snd = snd * -20.dbamp;
	snd = RLPF.ar(snd,LinExp.kr(\filter.kr(100).lag(0.2)+0.01,0.01,1,100,16000),0.707);
	Out.ar(\out.kr(0), snd);
}).add;

)

(
~track1="
0 repeat=1 gate=50 filter=99
1 repeat=1 gate=50
2 gate=50
2 repeat=1 pitch=1 gate=50
2 repeat=2 pitch=2 gate=50
2 repeat=4 pitch=3 gate=50
g
0
1 decimate=50
2 decimate=99
h decimate=99
4 decimate=50
5
5 repeat=2
5 repeat=4
5 repeat=6
6
7
4 repeat=1
5 repeat=1
6
0 filter=50 
0 repeat=2 filter=25
0 repeat=4 filter=10
0 repeat=6 filter=2
";
)

(
Buffer.read(Server.default, thisProcess.nowExecutingPath.dirname++"/shs_roam_breaks_loop_120_surge_full_key_bpm120_beats32_.flac", action: {arg buf;
	~bpm_source=120;
	~buffer=buf;
	~slices=(buf.duration/(60/~bpm_source));
});
);

(
Routine {
	var s, bpm, beat, tatum, fx, busFx;
	bpm = 120;
	beat = 60 / bpm / 2;
	tatum = beat / 4;
	s = Server.default.postln;

	busFx = Bus.audio(s,2);
	fx = Synth.tail(s, \fx, [\in, busFx]);
	s.sync;

	loop {
		var stretch = 0;
		var gate = 100;
		var filter = 100;
		var time = 0;
		~track1.split($\n).do { |line,i|
			var synth;
			var parts;
			var pitch = 0;
			var repeat = 1;
			var decimate = 100;
			var rampup = 0;
			parts = line.stripWhiteSpace.split($ );
			if (parts[0].size > 0) {
				parts.do { |part|
					if (part[.."pitch".size - 1]=="pitch") {
						pitch = part.split($=)[1].asInteger;
					};
					if (part[.."repeat".size - 1]=="repeat") {
						repeat = part.split($=)[1].asInteger;
					};
					if (part[.."gate".size - 1]=="gate") {
						gate = part.split($=)[1].asInteger;
					};
					if (part[.."filter".size - 1]=="filter") {
						filter = part.split($=)[1].asFloat / 100.0;
					};
					if (part[.."decimate".size - 1]=="decimate") {
						decimate = part.split($=)[1].asFloat / 100.0;
					};
					if (part[.."stretch".size - 1]=="stretch") {
						stretch = part.split($=)[1].asFloat / 100.0;
					};
					if (part[.."rampup".size - 1]=="rampup") {
						rampup = part.split($=)[1].asInteger>0;
					};
				};

				time = time + 1;
				fx.set(*[
					pitch1: (time % 16 / 16 * 0.1).coin,
					pitch2: (time % 16 / 16 * 0.1).coin,
					decimator: decimate,
					filter: filter,
				]);
				repeat.do {
					var duration= tatum / repeat * gate / 100;
					s.makeBundle(s.latency,{
						switch (parts[0][0],
							$g, {
								synth = Synth.head(s,\glitch, [
									out: busFx,
									modFreq: exprand(100,3000),
									carrierFreq: exprand(100, 3000) * pitch.midiratio.postln,
									index: rrand(100,8000),
									pan: rrand(-0.9,0.9),
									duration: duration,
									rampup: rampup,
								]);
							},
							$h, {
								synth = Synth.head(s,\bass, [
									out: busFx,
									freq: rrand(100,400),
									pan: rrand(-0.9,0.9),
								]);
							},
							{
								var synthName = \slice;
								if (stretch > 0) {
									synthName = \sliceStretch;
								}
								synth = Synth.head(s,\slice, [
									out: busFx,
									buf: ~buffer,
									slices: ~slices,
									slice: "0123456789abcdef".indexOf(parts[0][0]).postln,
									rate: bpm / ~bpm_source * pitch.midiratio.postln,
									stretch: stretch,
									pan: rrand(-0.3,0.3),
									duration: duration,
									rampup: rampup,
								]);
							}
						);
					});
					(tatum / repeat).wait;
					s.makeBundle(s.latency, {
						synth.set(\gate, 0);
					});
				};
			};
		};
	};
}.play;
)