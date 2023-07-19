(
s.waitForBoot({
	s.meter;
	s.plotTree;
	s.scope;

	Routine{
		b=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/54.4.5.1.0.wav",channels:[0]);

		s.sync;

		(
			{
				var sig;
				var rev;
				var bufDur = BufDur.ir(b);
				var freq=MouseY.kr(0.05,30);
				var dur=LFNoise2.kr(0.2!4).range(0.9,3)/freq;
				var dur01 = 0.1 / bufDur;
				var spray=LFNoise2.kr(1!4).range(dur01.neg,dur01);
				sig = GrainBuf.ar(
					numChannels:2,
					trigger: Impulse.ar([freq,freq+0.5,freq-0.5,freq+0.2]),
					dur: dur,
					sndbuf: b,
					rate: [0,4,9].midiratio,
					pos: MouseX.kr()+spray,
					interp: 4,
					pan: 0,
					envbufnum: -1,
					maxGrains:64,
					mul: [1,0.5,0.25,0.1],
				);

				sig = (sig).tanh;
				sig = Mix.new(Pan2.ar(sig,LFNoise2.kr(0.2!4)));
				rev = Fverb.ar(sig[0],sig[1],predelay:50,tail_density:LFNoise2.kr(1/3).range(70,90),decay:LFNoise2.kr(1/3).range(70,90));
				sig = SelectX.ar(LFNoise2.kr(1/3).range(0.1,0.4),[sig,rev]);
				//sig = AnalogTape.ar(sig,0.9,0.9,0.9,4);
				Out.ar(0,sig/2);
			}.play;
		)

	}.play;
});
)
