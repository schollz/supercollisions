(
s.waitForBoot({
	Routine{
		var n, mu, unit, fuzzCurve;
		var bufs=Dictionary.new();
		n = 512*8;
		mu = 255*2;
		unit = Array.fill(n, {|i| i.linlin(0, n-1, -1, 1) });
		fuzzCurve = unit.collect({ |x|
			x / (1 + x.abs);
			// x.sign * log(1 + mu * x.abs) / log(1 + mu);
		});
		bufs.put("fuzzBuf",Buffer.loadCollection(s,Signal.newFrom(fuzzCurve).asWavetableNoWrap));

		SynthDef("fx",{
			var rev,freq,dur;
			var ampscale;
			var snd=In.ar(0,2);
			freq = LFNoise2.kr(1/5).range(0.1,10);
			dur = LFNoise2.kr(1/5).range(0.5,4);
			snd = [GrainIn.ar(
				numChannels: 1,
				trigger: Impulse.kr(freq),
				dur: dur/freq,
				in: snd[0],
				maxGrains: 64,
			),GrainIn.ar(
				numChannels: 1,
				trigger: Impulse.kr(freq),
				dur: dur/freq,
				in: snd[1],
				maxGrains: 64,
			)];

			rev = Fverb.ar(snd[0],snd[1],
				predelay:50,
				tail_density:LFNoise2.kr(1/3).range(50,90),
				decay:LFNoise2.kr(1/3).range(50,90)
			);
			/*ampscale=Amplitude.kr(snd,0.1,0.1)/Amplitude.kr(snd,3,3);
			snd = SelectX.ar(Lag.kr(Clip.kr(1-ampscale,0,0.7),1).poll,[snd,rev]);*/
			ReplaceOut.ar(0,snd);
		}).add;

		SynthDef("grain",{
			arg buf,db=0,fuzzBuf,fuzzDrive,fuzzWet;
			var sndFuzz;
			var snd,freq,dur;
			snd = PlayBuf.ar(1,buf,loop:1);
			snd = Pan2.ar(snd,LFNoise2.kr(0.7));
			Out.ar(0,snd * 6.neg.dbamp * db.dbamp);
		}).add;

		s.sync;
		b=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/2023-08-04-202014_1.wav",channels:[0]);
		c=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/2023-08-04-202032_1.wav",channels:[0]);
		d=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/2023-08-04-202050_1.wav",channels:[0]);
		e=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/2023-08-04-202108_1.wav",channels:[0]);
		f=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/2023-08-04-202126_2.wav",channels:[0]);
		g=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/2023-08-04-202144_1.wav",channels:[0]);


		s.sync;
		x = Synth.tail(s,"fx");
		y = Synth.head(s,"grain",[\buf,b]);
		y = Synth.head(s,"grain",[\buf,c]);
		y = Synth.head(s,"grain",[\buf,d]);
		y = Synth.head(s,"grain",[\buf,e]);
		y = Synth.head(s,"grain",[\buf,f,\db,6]);
		y = Synth.head(s,"grain",[\buf,g]);
	}.play;
});
)