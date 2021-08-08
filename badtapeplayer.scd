// forked from https://sccode.org/1-5bP#c960
(
s.waitForBoot({

	SynthDef(\wowflutter_2chan, {
		arg bufnum, out = 0, wobble_rpm=33, wobble_amp=0.05, wobble_exp=39, flutter_amp=0.03, flutter_fixedfreq=6, flutter_variationfreq=2;
		var signed_wobble = wobble_amp*(SinOsc.kr(wobble_rpm/60)**wobble_exp);
		var wow = Select.kr(signed_wobble > 0, signed_wobble, 0);
		var flutter = flutter_amp*SinOsc.kr(flutter_fixedfreq+LFNoise2.kr(flutter_variationfreq));
		var combined_defects = 1 + wow + flutter;
		var sig = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum)*combined_defects*EnvGen.kr(Env.asr(1,1,curve:1)), doneAction:Done.freeSelf);

		sig=sig+LPF.ar(PinkNoise.ar(Amplitude.kr(sig)*0.1),LinExp.kr(Amplitude.kr(sig),0,0.2,60,900));

		sig=Compander.ar(sig,sig,
			thresh: 0.1,
			slopeBelow: 1,
			slopeAbove: 0.3,
			clampTime:  0.001,
			relaxTime:  0.1,
		);
		Out.ar(out, sig);
	}).add;

	b = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/beats16_bpm150_Ultimate_Jack_Loops_014__BPM_150_.wav"); // link in code description, or use your own...
	s.sync;

	Synth(\wowflutter_2chan ,[
		\bufnum, b.bufnum,
		\out, 0,
		\wobble_rpm, 33,
		\wobble_amp, 0.06,
		\wobble_exp, 11, // best an odd power, higher values produce sharper, smaller peak
		\flutter_amp, 0.03,
		\flutter_fixedfreq, 6,
		\flutter_variationfreq, 2
	]);
});
)

Decimator
