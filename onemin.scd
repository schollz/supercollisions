// Ctrl+Enter to run
// Ctl+Period to stop
(
s.waitForBoot({
	SynthDef("slice",{
		// posStart fractional (0-1)
		arg buf, bufmono, rate = 1, posStart=0, dur=0.5, bpmOriginal = 120, bpmTarget = 120, combdelay = 0, gverb = 0, lpf = 20000, hpf = 20, pan = 0, doReverse=0, doStretch;
		var snd;
		var phase;
		var xfade = 0.01; // 10 milliseconds crossfade

		rate = rate * BufRateScale.ir(buf) * bpmTarget / bpmOriginal;
		rate = (rate * 1.neg * doReverse) + ((1-doReverse) * rate);
		rate = (rate * 0.1 * doStretch) + ((1-doStretch) * rate);
		phase = Phasor.ar(trig: 1,
			rate: rate,
			start: posStart*BufFrames.ir(buf),
			end: BufFrames.ir(buf),
			resetPos: posStart*BufFrames.ir(buf),
		);
		snd = BufRd.ar(numChannels:2,
			bufnum: buf,
			phase: phase,
			loop: 1,
			interpolation: 4,
		);

		snd = snd * EnvGen.ar(Env.new([0,1,1,0],[xfade,dur-xfade,xfade]),doneAction:2);

		snd = SelectX.ar(doStretch,[snd,GrainBuf.ar(1,Impulse.kr(bpmTarget/60*4),1/(bpmTarget/60*4),bufmono,1,phase/BufFrames.ir(bufmono))]);

		snd = SelectX.ar(combdelay,[snd, snd +
			Pan2.ar(CombN.ar(snd[0], 0.02, Rand(0.01,0.06), Rand(1,2)),-1) +
			Pan2.ar(CombN.ar(snd[1], 0.02, Rand(0.01,0.06), Rand(1,2)),1) +
			Pan2.ar(CombN.ar(snd[0], 0.02, Rand(0.005,0.04), Rand(1,3)),-1,0.2) +
			Pan2.ar(CombN.ar(snd[1], 0.02, Rand(0.005,0.04), Rand(1,3)),1,0.2)
		]);

		snd = SelectX.ar(gverb,[snd,FreeVerb2.ar(snd[0],snd[1],1,0.9,0.1)]);

		snd = RLPF.ar(snd, lpf, 0.6);
		snd = RHPF.ar(snd, hpf, 0.65);

		snd = Balance2.ar(snd[0],snd[1],pan);

		//snd = snd * MouseY.kr(-96,0).dbamp;

		Out.ar(3, snd);
	}).add;

	s.sync;
	SynthDef("rhubarb",{
		arg note=60,detune=0.04,dur=1;
		var snd;
		var env;
		var freq = [note+Rand(detune.neg,detune),note+Rand(detune.neg,detune),note+Rand(detune.neg,detune)].midicps;
		// SinOsc SinOscFB Saw LFTri VarSaw
		snd = Saw.ar(freq);
		snd = RLPF.ar(snd, freq);
		snd = Splay.ar(snd);
		env = EnvGen.ar(Env.new([0,1,1,0],[0.1,dur,0.1]),doneAction:2);
		Out.ar(0,snd * 24.neg.dbamp * env);
	}).add;
	s.sync;
	SynthDef("main",{
		var snd, sndDrums;
		var rev;
		var drumAmp;
		snd = In.ar(0,2);
		sndDrums = In.ar(3,2);

		// we can do main effects on the total sound
		// rev = FreeVerb2.ar(snd[0],snd[1],0.5,0.9,0.2);
		rev = Fverb.ar(snd[0],snd[1],200,tail_density: LFNoise2.kr(1/3).range(50,90),decay: LFNoise2.kr(1/3).range(50,70));

		snd = SelectX.ar(MouseY.kr(),[snd,rev]);


		drumAmp = Amplitude.kr(Mix.new(sndDrums));
		// snd = snd * Clip.kr(1.0-drumAmp,0.1,1);
		snd = Compander.ar(snd, sndDrums*MouseX.kr(0,2), 0.05,1,1,0.1);

		snd = snd + (sndDrums*18.neg.dbamp * EnvGen.ar(Env.new([-64,0,0,-64],[8,60-16,8])).dbamp);

		snd = RHPF.ar(snd,60);

		snd = AnalogTape.ar(snd,0.8,0.8,0.8,2);

		ReplaceOut.ar(0,snd*24.dbamp);
	}).add;
	s.sync;
	//Synth("rhubarb",[\note,60,\dur,3]);


	b = Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/drums_bpm120.flac",action:{
		"buffer loaded!".postln;
	});
	~bmono = Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/drums_bpm120.flac",0,-1,[0]);

	s.sync;

	Routine{
		var bpmOriginal = 120;
		var bpmTarget = 136;
		Synth.tail(s, "main");
		// Pbind(
		// 	\instrument, "rhubarb",
		// 	\detune, Pseq([0.1,0.05,0.02],inf),
		// 	\note, Pseq([
		// 		// [62-24,62, 66, 69-12],   // D, 2 beats
		// 		// [54-24,54, 57, 61],  // F#min, 4 beats
		// 		// [54, 57, 61, 64], // F#min7, 2 beats
		// 		// [61, 64, 68-12, 71-12],  // C#min7, 2 beats
		// 		// [62, 66-12, 69-12],  // D, 4 beats
		// 		// [62, 66, 69-12],   // D, 2 beats
		// 		// [54, 57, 61],  // F#min, 4 beats
		// 		// [54, 57, 61, 64], // F#min7, 2 beats
		// 		// [61, 64, 68-12, 71-12],  // C#min7, 2 beats
		// 		// [62, 66-12, 69-12],  // D, 4 beats
		// 		[60, 64, 67],  // C Major, 4 beats
		// 		[57, 60, 64],  // A minor, 4 beats
		// 		[52, 55, 59],  // E minor, 4 beats
		// 		[53, 57, 60, 65],  // F Major, 4 beats
		// 	],inf),
		// 	\dur, Pseq([
		// 		2,4,2,2,4,2,4,2,2,4,
		// 	],inf),
		// ).play;

		Pbind(
			\bufmono, ~bmono,
			\instrument, \slice,
			\posStart, Pseq([
				Pseq((0..15),1),
				Prand([1,2,3,4],1),
				Pseq([0,0,0,0,0,0,0,0],1),
				Pseq([0,4,8,12],1),
				Prand((0..15),8),
			]/16,inf),
			\dur, Prand([8,4,4,2,2,2,2,1,1,1,1,1,1,1,0.5,0.5,0.5,0.25,0.25,0.125,0.125,0.125/2],inf)*60 / bpmTarget,
			\bpmOriginal, bpmOriginal,
			\bpmTarget, bpmTarget,
			\doStretch, Prand([0,0,0,0,0,1],inf),
			\combdelay, Prand([0,0,0,0,0,1],inf),
			\gverb, Prand([0,0,0,0,0,0.5,1],inf),
			\rate, Prand([1,1,1,1,1,0.5,1,0.25,1,2],inf),
			\lpf, Pwhite(90,120).midicps,
			\hpf, Pwhite(20,150),
			\doReverse, Prand([0,0,0,0,0,0,0,0,0,1],inf),
			\pan, Pseq([
				Pseq([0],4),
				Prand([-0.2,0.2],8),
				Prand([0.1,-0.1],8),
			],inf),
		).play;
	}.play;

});
)