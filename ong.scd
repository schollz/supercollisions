(
s.waitForBoot({
	Routine {
		// synth
		SynthDef(\Ong, {
			arg out,
			overallAmpl=1.0,
			nearWavesBaseAmpl=0.8,
			nearWavesSpeedL=0.07,
			nearWavesSpeedR=1/13,
			nearWavesFilterCutoff=3000,
			farWavesBaseAmpl=0.7,
			farWavesSpeed=1/11,
			farWavesFilterCutoff=840,
			nearFoamAmpl=0.07,
			ambienceAmpl=0.02,
			ambienceFilterCutoff=3000;

			//---- LFOs
			var nearWavesAmplL = SinOsc.ar(nearWavesSpeedL, 0.0, nearWavesBaseAmpl);
			var nearFoamAmplL = SinOsc.ar(nearWavesSpeedL, 2*(pi/3), nearFoamAmpl);
			var nearWavesAmplR = SinOsc.ar(nearWavesSpeedR, 0.0, nearWavesBaseAmpl);
			var nearFoamAmplR = SinOsc.ar(nearWavesSpeedR, 2*(pi/3), nearFoamAmpl);
			var farWavesAmpl = SinOsc.ar(farWavesSpeed, 0.0, farWavesBaseAmpl);

			//---- sound generators
			var nearWavesL = LPF.ar(PinkNoise.ar(1.0, 0.0), LFNoise2.kr(1/5).range(nearWavesFilterCutoff/2,nearWavesFilterCutoff*2), 1.0, 0.0);
			var nearFoamL = LPF.ar(PinkNoise.ar(1.0, 0.0),LFNoise2.kr(1/3).range(10000,20000));
			var nearWavesR = LPF.ar(PinkNoise.ar(1.0, 0.0), LFNoise2.kr(1/5).range(nearWavesFilterCutoff/2,nearWavesFilterCutoff*2), 1.0, 0.0);
			var nearFoamR = LPF.ar(PinkNoise.ar(1.0, 0.0),LFNoise2.kr(1/3).range(10000,20000));
			var farWaves = LPF.ar(PinkNoise.ar(1.0, 0.0), LFNoise2.kr(1/5).range(farWavesFilterCutoff*0.7,farWavesFilterCutoff*1.2), 1.0, 0.0);
			var ambience = LPF.ar(WhiteNoise.ar(1.0, 0.0), LFNoise2.kr(1/3).range(2000,4000), 1.0, 0.0);

			// Create an output object
			Out.ar(out, [
				Mix.new([
					nearWavesL * 0.7 * nearWavesAmplL,
					nearWavesR * 0.1 * nearWavesAmplR,
					nearFoamL * nearFoamAmplL*nearFoamAmplL,
					ambience * ambienceAmpl,
					farWaves * farWavesAmpl
				]) * overallAmpl, // left stereo
				Mix.new([
					nearWavesL * 0.1 * nearWavesAmplL,
					nearWavesR * 0.7 * nearWavesAmplR,
					nearFoamR * nearFoamAmplR*nearFoamAmplR,
					ambience * ambienceAmpl,
					farWaves * farWavesAmpl
				]) * overallAmpl  // right stereo
			]);
		}).add;

		// foghorn as used by ships
		SynthDef(\Foghorn, {
			arg out, vol = 0.1;

			var pan = Rand(0.1, 0.9);
			var dur = Rand(2.0, 8.0);
			var freq = IRand(35, 60);
			var amp = Env([0, 1, 0.6, 0.8, 0], [0.1, 0.2, dur, 0.2]);
			var wave = Saw.ar(freq, 1.0);

			// FreeVerb.ar(in, mix, roomsize, damp, mul, add)
			var filtered = FreeVerb.ar(
				LPF.ar(
					Decay.ar(wave, 0.25, LFCub.ar(freq*2.04, 0, 0.2)),
					500,
					EnvGen.kr(amp)
			), 0.8, 0.7, 0.7, vol);

			filtered = Limiter.ar(filtered, 0.8);

			Out.ar(out, [filtered * pan, filtered * (1.0-pan)]);
			FreeSelfWhenDone.kr(Line.kr(vol, 0, dur+2));
		}).add;

		SynthDef("fx",{
			var snd=In.ar(0,2);
			var rev = Fverb.ar(snd[0],snd[1],
				predelay:50,
				tail_density:LFNoise2.kr(1/3).range(70,90),
				decay:LFNoise2.kr(1/3).range(70,90)
			);
			snd = SelectX.ar(LFNoise2.kr(1/3).range(0.3,0.6),[snd,rev]);
			ReplaceOut.ar(0,snd*MouseX.kr());
		}).add;

		s.sync;

		y = Synth.tail(s,"fx");
		x=Synth.head(s,\Ong);


		inf.do({
			(60.rand).wait;
			Synth(\Foghorn,[\vol,40.rand/10]);
		});
	}.play;

});
)
