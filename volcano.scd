(
s.waitForBoot({
	b=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/909_1.wav");
	s.sync;
	SynthDef("kick",{
		var snd = PlayBuf.ar(1,b);
		var snd1 = HPF.ar(snd,90);
		var snd1r, snd1l, snd1rl;
		// snd1 = (snd1*20).tanh;
		snd1 = AnalogVintageDistortion.ar(snd1,0.2,0.0,0.1,0.2);

		// reverb predelay time :
		snd1r = DelayN.ar(snd1, 0.02 + 0.03.rand);
		// 7 length modulated comb delays in parallel :
		snd1r = Mix.ar(Array.fill(7,{ CombL.ar(snd1r, 0.1, LFNoise1.kr(0.001.rand, 0.04, 0.05), 15.rand) }));
		// two parallel chains of 4 allpass delays (8 total) :
		4.do({ snd1r = AllpassN.ar(snd1r, 0.050, [0.050.rand, 0.050.rand], 1) });

		// reverb predelay time :
		snd1l = DelayN.ar(snd1, 0.02 + 0.03.rand);
		// 7 length modulated comb delays in parallel :
		snd1l = Mix.ar(Array.fill(7,{ CombL.ar(snd1l, 0.1, LFNoise1.kr(0.001.rand, 0.04, 0.05), 15.rand) }));
		// two parallel chains of 4 allpass delays (8 total) :
		4.do({ snd1l = AllpassN.ar(snd1r, 0.050, [0.050.rand, 0.050.rand], 1) });

		snd1 = Pan2.ar(snd1);

		snd1 = SelectX.ar(0.3,[snd1,[snd1l,snd1r]]);
		snd1 = snd1 * (1 - Amplitude.ar(snd));

		snd = Pan2.ar(snd,0);

		snd = (snd/2) + (snd1/2);

		snd = snd.tanh;

		snd = snd + CombC.ar(snd);

		snd = snd * EnvGen.ar(Env.new([1,1,0],[3,3],\sine));

		DetectSilence.ar(snd,doneAction:2);
		Out.ar(0,snd);
	}).play;
});
)


(
s.waitForBoot({
	b=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/909_1.wav");
	s.sync;
	SynthDef("kick",{
		arg decay = 1;
		var snd = PlayBuf.ar(1,b);
		var snd1 = HPF.ar(snd,90);
		var snd1r, snd1l, snd1rl;

		snd1 = (snd1*30).tanh;

		// reverb predelay time :
		snd1r = DelayN.ar(snd1, 0.02 + 0.03.rand);
		// 7 length modulated comb delays in parallel :
		snd1r = Mix.ar(Array.fill(11,{ CombL.ar(snd1r, 0.1, LFNoise1.kr(0.001.rand, 0.04, 0.05), EnvGen.kr(Env.perc(0.01,decay*2))*(15.rand)) }));
		// two parallel chains of 4 allpass delays (8 total) :
		4.do({ snd1r = AllpassN.ar(snd1r, 0.050, [0.050.rand, 0.050.rand], 1) });

		snd1 = SelectX.ar(0.3,[snd1,snd1r]);

		// snd1 = snd1 * (1 - Amplitude.ar(snd));

		snd = Pan2.ar(snd,0);

		snd = (snd/2) + (snd1/2);

		snd = snd.tanh  * 6.neg.dbamp;

		snd = snd + CombC.ar(snd,mul:2.rand);

		snd = snd * EnvGen.ar(Env.new([1,1,0],[decay,1],\sine),doneAction:2);
		Out.ar(0,snd);
	}).play;
});
)

b.play;