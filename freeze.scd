(
s.waitForBoot({
	SynthDef("freezer",{
		arg bufL, bufR, freeze=0, freezeTime=10, rate=1, impulseFreq = 10;
		var sndIn, sndGrain, snd, impulse;
		var freezeRecord = Latch.kr(freeze,TDelay.kr(Changed.kr(freeze),freezeTime));
		impulse = Impulse.kr(LFNoise2.kr(1/3).range(0.9,1.1)*impulseFreq);
		sndIn = SoundIn.ar([0,1]);
		RecordBuf.ar(
			inputArray: sndIn[0],
			bufnum: bufL,
			recLevel: VarLag.kr(1-freezeRecord,warp:\sine),
			preLevel: VarLag.kr(freezeRecord,warp:\sine),
		);
		RecordBuf.ar(
			inputArray: sndIn[1],
			bufnum: bufR,
			recLevel: VarLag.kr(1-freezeRecord,warp:\sine).poll,
			preLevel: VarLag.kr(freezeRecord,warp:\sine),
		);
		sndGrain = GrainBuf.ar(
			numChannels: 2,
			trigger: impulse + Dust.kr(impulseFreq/10),
			dur: LFNoise2.kr(1).range(0.6,1.5)*1/impulseFreq,
			sndbuf: bufL,
			rate: rate,
			pos: LFNoise0.kr(10).range(0.2,0.8),
			pan: -1,
			maxGrains: 256,
		) + GrainBuf.ar(
			numChannels: 2,
			trigger: impulse + Dust.kr(impulseFreq/10),
			dur: LFNoise2.kr(1).range(0.8,1.2)*1/impulseFreq,
			sndbuf: bufR,
			rate: rate,
			pos: LFNoise0.kr(10).range(0.2,0.8),
			pan: 1,
			maxGrains: 256,
		);
		snd = SelectX.ar(VarLag.kr(freeze,freezeTime,warp:\sine),[sndIn,sndGrain+(LFNoise2.kr(1/3).range(0.2,0.5)*[
			PlayBuf.ar(1,bufL,loop:1),
			PlayBuf.ar(1,bufR,loop:1),
		])]);
		Out.ar(0,snd);
	}).add;

	~bufL = Buffer.alloc(s,2 * s.sampleRate,1);
	~bufR = Buffer.alloc(s,2 * s.sampleRate,1);
	s.sync;
	~freezer = Synth.head(s, "freezer", [
		bufL: ~bufL,
		bufR: ~bufR,
	]);
})
)

~freezer.set(\freeze,0)
~freezer.set(\freeze,1)
~freezer.set(\impulseFreq,10)

({
	var trigger = EnvGen.kr(Env.new([0,0,1,1,0,0],[1,0,1,0,1]),timeScale:0.25);
	[trigger,VarLag.kr(trigger,0.2,warp:\sine)]
}.plot(0.75))

0.1.ratiomidi
-12.midiratio
