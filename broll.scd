
(
SynthDef("samplePlayer6", {
	arg out=0, bufnum=0, rate=1, rateLag=0,start=0, end=1, reset=0, t_trig=1,
	loops=1, amp=0.5, resetFreq=1, loopRate=1,loopRange=0.5;
	var snd,snd2,pos,pos2,frames,duration,env;
	var startA,endA,startB,endB,resetA,resetB,crossfade,aOrB;

	// THESE LINES ARE AMAZING
	// INSPIRED FROM the b-roll: https://www.youtube.com/watch?v=g6xdPRGHLLg
	t_trig=Trig.kr(Impulse.kr(resetFreq));
	reset=LinLin.kr(SinOsc.kr(loopRate,0,loopRange),-1,1,0,1);

	aOrB=ToggleFF.kr(t_trig);
	startA=Latch.kr(start,aOrB);
	endA=Latch.kr(end,aOrB);
	resetA=Latch.kr(reset,aOrB);
	startB=Latch.kr(start,1-aOrB);
	endB=Latch.kr(end,1-aOrB);
	resetB=Latch.kr(reset,1-aOrB);
	crossfade=Lag.ar(K2A.ar(aOrB),0.05);


	rate = Lag.kr(rate,rateLag);
	rate = rate*BufRateScale.kr(bufnum);
	frames = BufFrames.kr(bufnum);
	duration = frames*(end-start)/rate.abs/s.sampleRate*loops;

	// envelope to clamp looping
	env=EnvGen.ar(
		Env.new(
			levels: [0,1,1,0],
			times: [0,duration-0.05,0.05],
		),
		gate:t_trig,
	);

	pos=Phasor.ar(
		trig:aOrB,
		rate:rate,
		start:(((rate>0)*startA)+((rate<0)*endA))*frames,
		end:(((rate>0)*endA)+((rate<0)*startA))*frames,
		resetPos:(((rate>0)*resetA)+((rate<0)*endA))*frames,
	);
	snd=BufRd.ar(
		numChannels:2,
		bufnum:bufnum,
		phase:pos,
		interpolation:4,
	);

	// add a second reader
	pos2=Phasor.ar(
		trig:(1-aOrB),
		rate:rate,
		start:(((rate>0)*startB)+((rate<0)*endB))*frames,
		end:(((rate>0)*endB)+((rate<0)*startB))*frames,
		resetPos:(((rate>0)*resetB)+((rate<0)*endB))*frames,
	);
	snd2=BufRd.ar(
		numChannels:2,
		bufnum:bufnum,
		phase:pos2,
		interpolation:4,
	);

	Out.ar(out,(crossfade*snd)+((1-crossfade)*snd2) * env * amp)
}).add;
)

~buffer=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/aquatic.flac");
x=Synth("samplePlayer6", [\bufnum, ~buffer]); // will start playing

// try different combos...
x.set(\resetFreq,2,\loopRate,0.5,\loopRange,0.1)
x.set(\resetFreq,1,\loopRate,0.7,\loopRange,0.4)
x.set(\resetFreq,4,\loopRate,0.2,\loopRange,0.01)
x.set(\resetFreq,0.5,\loopRate,0.2,\loopRange,0.5)
