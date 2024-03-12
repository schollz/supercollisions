(
s.waitForBoot({
	SynthDef("freezer",{
		arg bufL, bufR, freeze=0, rate=1;
		var sndIn, sndGrain, snd;
		sndIn = SoundIn.ar([0,1]);
		RecordBuf.ar(
			inputArray: sndIn[0],
			bufnum: bufL,
			recLevel: VarLag.kr(1-freeze,warp:\sine),
			preLevel: VarLag.kr(freeze,warp:\sine),
		);
		RecordBuf.ar(
			inputArray: sndIn[1],
			bufnum: bufR,
			recLevel: VarLag.kr(1-freeze,warp:\sine),
			preLevel: VarLag.kr(freeze,warp:\sine),
		);
		sndGrain = GrainBuf.ar(
			numChannels: 2,
			trigger: Impulse.kr(10),
			dur: LFNoise2.kr(1).range(0.8,1.2)*0.1,
			sndbuf: bufL,
			rate: rate,
			pos: LFNoise0.kr(10).range(0.2,0.8),
			pan: -1,
			maxGrains: 256,
		) + GrainBuf.ar(
			numChannels: 2,
			trigger: Impulse.kr(10),
			dur: LFNoise2.kr(1).range(0.8,1.2)*0.1,
			sndbuf: bufR,
			rate: rate,
			pos: LFNoise0.kr(10).range(0.2,0.8),
			pan: 1,
			maxGrains: 256,
		);
		snd = SelectX.ar(VarLag.kr(freeze,1,warp:\sine),[sndIn,sndGrain]);
		Out.ar(0,snd);

		~bufL = Buffer.alloc(s,2 * s.sampleRate,1);
		~bufR = Buffer.alloc(s,2 * s.sampleRate,1);
		s.sync;
		~freezer = Synth.head(s, "freezer", [
			bufL: ~bufL,
			bufR: ~bufR,
		]);
	}).add;
})
)

({
	var trigger = EnvGen.kr(Env.new([0,0,1,1,0,0],[1,0,1,0,1]),timeScale:0.25);
	[trigger,VarLag.kr(trigger,0.2,warp:\sine)]
}.plot(0.75))
~freezer.set(\freeze,1)
0.1.ratiomidi
-12.midiratio
