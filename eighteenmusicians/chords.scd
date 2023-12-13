(
s.waitForBoot{
	SynthDef("18musicians",{
		var dugens=Dseq([
			[30, 35, 50, 57, 62, 64, 69, 74, 0, 0, 0],
			[35, 42, 50, 52, 57, 62, 64, 81, 74, 0, 0],
			[37, 42, 52, 57, 64, 69, 83, 76, 0, 0, 0],
			[30, 37, 52, 57, 59, 64, 69, 71, 76, 0, 0],
			[26, 33, 52, 54, 56, 59, 64, 74, 0, 0, 0],
			[33, 40, 52, 54, 56, 59, 61, 64, 71, 0, 0],
			[37, 42, 54, 56, 57, 59, 61, 69, 73, 0, 0],
			[30, 37, 54, 56, 57, 59, 61, 66, 0, 0, 0],
			[28, 33, 49, 54, 56, 57, 59, 64, 68, 71, 76],
			[26, 33, 54, 56, 57, 64, 68, 76, 0, 0, 0],
			[33, 38, 52, 54, 57, 64, 69, 0, 0, 0, 0],
		],inf);
		var notes=Demand.kr(Impulse.kr(1/11*4),0,dugens).poll;
		var snd;
		snd=Array.fill(11,{ arg i;
			var imp=Impulse.kr((12-i)/11*8);
			var note=Select.kr(i,notes);
			var sn = Saw.ar((note+rrand(-0.1,0.1)).midicps,0.5);
			var nnote=Latch.kr(note,Changed.kr(note)*(note>0));
			sn = RLPF.ar(sn,Lag.kr(nnote,0.05).midicps*2,0.707);
			sn = sn * Lag.kr(note>0,2);
			sn = sn * EnvGen.ar(Env.perc(0.01,0.5),imp);
			sn = Pan2.ar(sn,LFNoise2.kr(1/Rand(5,11))/4);
			sn
		});
		snd = Mix.ar(snd);
		snd = snd / 11;
		// snd = CombC.ar(snd,0.2,0.2,1.5);
		snd = AnalogTape.ar(snd,0.9,0.9,0.9,2);
		snd = Select.ar(LFNoise2.kr(1/Rand(5,9)).range(0.8,1),[snd,Fverb.ar(snd[0],snd[1],120,decay:LFNoise2.kr(1/7).range(50,90))]);
		Out.ar(0,snd);
	}).send(s);
	s.sync;

	a=Synth("18musicians");
};
)
