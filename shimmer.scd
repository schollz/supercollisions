(
s.waitForBoot({
	SynthDef("a",{
		var snd2,snd;
		var wet=0.5;
		var tail=MouseX.kr(0.1,4);
		var shimmer=MouseY.kr(0,0.5);
		var bassnote,index;

		// some chords
		var chord=Demand.kr(Impulse.kr(1/4),0,Dseq([
			[0,4,7,12],
			[-1,4,7,12],
			[-3,4,7,12],
			[-3,4,7,11],
			[0,4,7,12,-12],
			[-1,4,7,12,-12],
			[-3,4,7,12,-12],
			[-3,4,7,11,-12],
		],inf));

		#bassnote,index=ArrayMin.kr(chord);
		snd = SinOsc.ar((chord+60).midicps);
		snd = Splay.ar(snd);
		snd = snd * EnvGen.ar(Env.perc(0.01,0.9),Impulse.kr(1));
		snd2 = DelayN.ar(snd, 0.03, 0.03);

		// SHIMMER
		snd2 = snd2 + PitchShift.ar(snd, 0.13, 2,0,1,1*shimmer);
		snd2 = snd2 + PitchShift.ar(snd, 0.1, 4,0,1,0.5*shimmer);
		snd2 = snd2 + PitchShift.ar(snd, 0.1, 8,0,1,0.25*shimmer);

		// BASIC REVERB (from Eli Fieldsteel)
		snd2 = DelayC.ar(snd2, 0.2, SinOsc.ar(0.3, [0, pi]).linlin(-1,1,0,0.001));
		snd2 = CombN.ar(snd2, 0.1, {Rand(0.01,0.099)}!32, 0.1+(tail*2));
		snd2 = SplayAz.ar(2, snd2);
		5.do{snd2 = AllpassN.ar(snd2, 0.1, {Rand(0.01,0.099)}!2, 0.1+(tail*1.5))};
		snd2 = LeakDC.ar(snd2);

		// mix wet and dry
		snd = ((1-wet)*snd)+(wet*snd2);
		snd = snd + SinOscFB.ar((bassnote+48).midicps,LFNoise2.kr(1/3).range(0,0.5),0.1);
		Out.ar(0,snd * -10.dbamp);
	}).send(s);
	s.sync;
	Synth.new("a");
});
)