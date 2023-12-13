(
s.waitForBoot({
	SynthDef("f",{
		arg note=12;
		var lfo=SinOsc.kr(3);
		var freq=(note+(lfo*0.2)).midicps;
		var snd;

		snd = SinOscFB.ar(freq,lfo.range(0.1,LFNoise2.kr(Rand(1,2)).range(1,3)));
		snd = LPF.ar(snd,note.midicps*8);
		snd = Pan2.ar(snd,LFNoise2.kr(1,0.25));

		snd = snd * 24.neg.dbamp;
		Out.ar(0,snd);
	}).send(s);


	SynthDef("fx",{
		var snd,rev;
		snd = In.ar(0,2);
		rev = Fverb.ar(snd[0],snd[1],
			predelay:50,
			tail_density:LFNoise2.kr(1/3).range(10,90),
			decay:LFNoise2.kr(1/3).range(10,90)
		);
		snd = SelectX.ar(LFNoise2.kr(1/3).range(0.1,0.5),[snd,rev]);
		ReplaceOut.ar(0,snd);
	}).send(s);

	s.sync;

	Synth.tail(s,"fx");
	Synth.head(s,"f",[\note,60-24]);
	Synth.head(s,"f",[\note,64]);
	Synth.head(s,"f",[\note,69]);
	Synth.head(s,"f",[\note,72]);
});
)