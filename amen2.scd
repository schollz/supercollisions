

(
SynthDef(\slice,{
	var snd;
	snd = PlayBuf.ar(2,\buf.kr(0),BufRateScale.kr(\buf.kr(0)) * \rate.kr(1),
		startPos: BufFrames.kr(\buf.kr(0)) * \slice.kr(0) / \slices.kr(16));
	snd = snd * Env.linen(0, BufDur.kr(\buf.kr(0)) / \slices.kr(16), 0.01).ar;
	snd = snd * Env.asr(0.001, 1, 0.001).ar(Done.freeSelf, \gate.kr(1) * (1-TDelay.kr(Impulse.kr(0),\duration.kr(100000))) );
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
	snd = snd * Env.asr(0.001, 1, 0.001).ar(Done.freeSelf, \gate.kr(1) * (1-TDelay.kr(Impulse.kr(0),\duration.kr(100000).poll)).poll );
	snd = snd * -6.dbamp ! 2;
	Out.ar(\out.kr(0),snd);
}).add;

SynthDef(\glitch,{
	var snd;
	snd = SinOsc.ar((SinOsc.ar(\modFreq.kr(3240)) * Env.perc(0.01,2).kr * \index.kr(3000) + \carrierFreq.kr(1000)));
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
	snd = snd * -10.dbamp;
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
	snd = RLPF.ar(snd,LinExp.kr(\filter.kr(1).lag(1)+0.01,0.01,1,100,16000),0.707);
	snd = CompanderD.ar(snd);
	snd = LPF.ar(snd,MouseX.kr(100,20000,1));
	Out.ar(\out.kr(0), snd);
}).add;

)

(
~track1="
h
0 repeat=1 gate=100 filter=99
0 repeat=1 gate=100
1 repeat=1 pitch=1 gate=53
2 repeat=2 pitch=2 gate=20
3 repeat=4 pitch=3 gate=100
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
0 repeat=2 filter=100
0 repeat=4 filter=50
0 repeat=6 filter=100
";
)

(
~track1="
0 gate=100 decimate=99
1 repeat=2 decimate=59
2 pitch=2 decimate=5
3 pitch=3 gate=100
4
5
7
6 repeat=4
b pitch=2 filter=60
c pitch=4 repeat=2 filter=80
d pitch=6 repeat=3 filter=90
e pitch=8 repeat=4 filter=100
";
)

(
~track1="
0 filter=60 gate=100 stretch=0
1 repeat=4 filter=50 gate=90
2 repeat=6 filter=50 gate=70
3 filter=100 gate=60
2 repeat=6 gate=50
3 gate=100
3
6 decimate=40
7 gate=70
8
9 gate=100
a
b pitch=2 filter=20
c pitch=4 repeat=2 filter=40
d pitch=6 repeat=3 filter=60
e pitch=8 repeat=4 filter=100
";
)

(
~track1="
0 stretch=60 filter=90 gate=50
1 stretch=23 repeat=4 gate=80
2 stretch=40 pitch=1 gate=100
3 stretch=39 pitch=2 gate=80
4 stretch=80 pitch=3 gate=100
5 stretch=10
6 stretch=40 pitch=-1
7 stretch=30 pitch=-2
8 stretch=60 pitch=-3
9 stretch=50 repeat=2
a stretch=40 repeat=4
b stretch=30 repeat=6
";
)

(
~track1="
0 gate=50 stretch=75
1
2
3
";
)

(
~track1="
0 filter=10 gate=100
1
2
3
4
5 filter=20
6
7
8
9
a filter=30
b
c
d
e filter=40 repeat=2
f repeat=4
0 filter=50
1
2
3
4
5 filter=60
6
7
8
9
a filter=70
b
c
d repeat=6
e filter=80 repeat=2
f repeat=4
0 filter=80
1
2
3
4
5 filter=90
6
7
8
9
a filter=99
b
c pitch=1
d repeat=2 pitch=2
e filter=100 repeat=4 pitch=3
f repeat=8 pithch=4
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
Buffer.read(Server.default, thisProcess.nowExecutingPath.dirname++"/amenbreak_bpm136.wav", action: {arg buf;
	~bpm_source=136;
	~buffer=buf;
	~slices=(buf.duration/(60/~bpm_source));
});
);

(
Routine {
	var s, bpm, beat, tatum, fx, busFx;
	bpm = 120;
	beat = 60 / bpm * 2;
	tatum = beat / 4;
	s = Server.default;

	busFx = Bus.audio(s,2);
	fx = Synth.tail(s, \fx, [\in, busFx]);
	s.sync;

	loop {
		var stretch = 0;
		var gate = 100;
		var filter = 1;
		var time = 0;
		~track1.split($\n).do { |line,i|
			var synth;
			var parts;
			var pitch = 0;
			var repeat = 1;
			var decimate = 0;
			var rampup = 0;
			parts = line.stripWhiteSpace.split($ );
			if (parts[0].size > 0) {
				parts.postln;
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
						filter = (part.split($=)[1].asFloat) / 100.0;
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
									carrierFreq: exprand(100, 3000) * pitch.midiratio,
									index: rrand(100,8000),
									pan: rrand(-0.9,0.9),
									duration: duration,
									rampup: rampup,
								]);
								NodeWatcher.register(synth);
							},
							$h, {
								synth = Synth.head(s,\bass, [
									out: busFx,
									freq: rrand(100,400),
									pan: rrand(-0.9,0.9),
								]);
								NodeWatcher.register(synth);
							},
							{
								var synthName = \slice;
								if (stretch > 0) {
									synthName = \sliceStretch;
								};
								synth = Synth.head(s, synthName, [
									out: busFx,
									buf: ~buffer,
									slices: ~slices,
									slice: "0123456789abcdef".indexOf(parts[0][0])%~slices,
									rate: bpm / ~bpm_source * pitch.midiratio,
									stretch: stretch,
									pan: rrand(-0.3,0.3),
									duration: duration,
									rampup: rampup,
								]);
								NodeWatcher.register(synth);
							}
						);
					});
					(tatum / repeat).wait;
					if (synth.notNil,{
						if (synth.isRunning,{
							s.makeBundle(s.latency, {
								synth.set(\gate, 0);
							});
						});
					});
				};
			};
		};
	};
}.play;
)