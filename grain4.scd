(
s.waitForBoot({
	Routine{
		SynthDef("fx",{
			var snd=In.ar(0,2);
			var rev = Fverb.ar(snd[0],snd[1],
				predelay:50,
				tail_density:LFNoise2.kr(1/3).range(50,90),
				decay:LFNoise2.kr(1/3).range(50,90)
			);
			snd = SelectX.ar(LFNoise2.kr(1/3).range(0.1,0.5),[snd,rev]);
			ReplaceOut.ar(0,snd);
		}).add;

		SynthDef("grain",{
			arg buf,freq=1,move=1,pos=0,t_jump=1,db=0,num=0;
			var snd,phase,rate,dur;
			// rate = MouseX.kr(2.neg,2);
			// freq = freq * MouseY.kr(0.1,10);
			rate = EnvGen.kr(Env.new([0.1,1,-1,0.1],[5,3,1]),Impulse.kr(1/9));
			freq = freq * EnvGen.kr(Env.new([0.1,10,2,0.1],[10,3,1]),Impulse.kr(1/13));
			dur = EnvGen.kr(Env.new([0.5,1.5,6,0.5],[3,8,1]),Impulse.kr(1/12));
			phase = Phasor.ar(
				trig:t_jump+TDelay.kr(Impulse.kr(0),0.01),
				rate:move*rate/BufFrames.ir(buf),
				start:MouseX.kr(0,0.5),
				end:MouseX.kr(0,0.5)+MouseY.kr(0.05,0.5),
				resetPos:Rand(0,1),
			);
			snd = GrainBuf.ar(
				numChannels: 2,
				trigger: Impulse.kr(freq),
				dur: dur/freq,
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
		// b=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/goalltheway.wav",channels:[0]);
		// b=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/c/test1.wav_loop.100.wav",channels:[0]);
		//b=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/DS_VPDH_126_piano_loop_arp_heaven_Cm_keyCmin_bpm126_beats32_.flac",channels:[0]);
		//b=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/vocals_bpm120_dm.wav",channels:[0]);
		// s.sync;
		// c=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/synth_dm_bpm130.flac",channels:[0]);
		b=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/windchimes.wav",channels:[0]);
		c=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/windchimes.wav",channels:[0]);
//		c=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/fss_ecv2_138_vocal_adlib_wet_soaring_arpeggio_high_Cm_keyCmin_bpm138_beats16_.flac",channels:[0]);
		//		c=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/wineglass.wav",channels:[0]);


		s.sync;
		x = Synth.tail(s,"fx");
		y = Synth.head(s,"grain",[\buf,b,\move,1,\db,-3]);
		z = Synth.head(s,"grain",[\buf,c,\move,1,\db,-9]);
	}.play;
});
)

y.set(\pos,0.0,\t_jump,1);
z.set(\pos,0.1,\t_jump,1);

(1.neg.sign)
