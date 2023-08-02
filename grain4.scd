(
s.waitForBoot({
	s.meter;
	s.plotTree;
	s.scope;

	Routine{

		s.sync;

		SynthDef("fx",{
			var snd=In.ar(0,2);
			var rev = Fverb.ar(snd[0],snd[1],
				predelay:50,
				tail_density:LFNoise2.kr(1/3).range(70,90),
				decay:LFNoise2.kr(1/3).range(70,90)
			);
			snd = SelectX.ar(LFNoise2.kr(1/3).range(0.1,0.4),[snd,rev]);
			ReplaceOut.ar(0,snd);
		}).add;

		SynthDef("grain",{
			arg buf,freq=1,move=1,pos=0,t_jump=0,db=0,num=0;
			var snd,phase,rate;
			rate = MouseX.kr(2.neg,2);
			phase = Phasor.ar(trig:t_jump,rate:move*rate/BufFrames.ir(buf),resetPos:pos).poll;
			freq = freq * MouseY.kr(0.1,10);
			snd = GrainBuf.ar(
				numChannels: 2,
				trigger: Impulse.kr(freq),
				dur: LFNoise2.kr(1/3).range(0.5,2)/freq,
				sndbuf: buf,
				pos: phase,
				rate: rate.sign*[1,0.5,2],
				interp: 4,
				pan: (LFNoise2.kr(1!3)),
				maxGrains: 64,
				mul: [1,0.25,0.05]
			);
			snd = Mix.new(snd);
			Out.ar(0,snd * 12.neg.dbamp * db.dbamp);
		}).add;

		s.sync;

		// b=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/vocals_bpm100.flac",channels:[0]);
		b=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/vocals_bpm120_dm.wav",channels:[0]);
		s.sync;
		c=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/synth_dm_bpm130.flac",channels:[0]);
		// b=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/kalimba.wav",channels:[0]);
		// d=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/pad_bpm124_dm.flac",channels:[0]);

		s.sync;
		x = Synth.tail(s,"fx");
		y = Synth.head(s,"grain",[\buf,b,\move,1]);
		z = Synth.head(s,"grain",[\buf,c,\move,0.5,\db,-6]);

	}.play;
});
)

y.set(\pos,0.4,\t_jump,1);
z.set(\pos,0.1,\t_jump,1);

(1.neg.sign)
