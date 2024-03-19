(
s.waitForBoot({

	SynthDef("meditate",{
		arg note;
		var freq = note.midicps + Rand(-1,1);
		var snd = SinOscFB.ar(freq, LFNoise2.kr(1/3).range(0.2,0.9));
		snd = snd * EnvGen.ar(Env.new([0,1],[Rand(1,5)]));
		snd = snd * LFNoise2.kr(1/3).range(-32,-12).dbamp;
		snd = Pan2.ar(snd,LFNoise2.kr(1/3));
		Out.ar(0,snd);
	}).add;
	s.sync;
	SynthDef("out",{ arg gate=1, in;
		var snd2;
		var shimmer=0.25;
		var snd=In.ar(0,2);
		snd2=snd/8;
		snd2=SelectX.ar(LFNoise2.kr(1/4).range(0.6,0.8),[snd2,Fverb.ar(snd2[0],snd2[1],200,
			decay:VarLag.kr(LFNoise0.kr(1/3),3).range(60,96),
			tail_density: LFNoise2.kr(1/3).range(70,90),
		)]);
		snd2=snd2*EnvGen.ar(Env.new([48.neg,0],[3])).dbamp;
		ReplaceOut.ar(0,snd2*EnvGen.ar(Env.adsr(sustainLevel:1,releaseTime:3),gate:gate,doneAction:2));
	}).send(s);

	s.sync;
	s.record;
	Synth.tail(s,"out");
	s.sync;
	~root=48;
	~octaves=[-1,0,0,0,0,1,1];
	~adds=[5,7,9,11];
	10.do({
		Synth.head(s,"meditate",[\note,~root+(12*~octaves.choose)+(~adds.choose)]);
	});
});
)