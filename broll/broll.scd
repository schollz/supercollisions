
// resettable sine wave
(
{
	var freq=4;
	var up=Phasor.kr(Impulse.kr(1.2),2*pi*s.options.blockSize/s.sampleRate*freq,0,2*pi)-0.01;
	[up,up.sin
	]
}.plot(1);
)

(
{
	var t_trig=1,resetFreq=10,lfo_trig,lfo1,up,freq=4;
	lfo1=Phasor.kr(t_trig,2*pi*s.options.blockSize/s.sampleRate*resetFreq,0,2*pi)-0.1;
	up=Phasor.kr(Impulse.kr(1.2),2*pi*s.options.blockSize/s.sampleRate*freq,0,2*pi)-0.01;
	[Trig.kr(lfo1>0,0.01),lfo1,up]
}.plot(1);
)

(
SynthDef("samplePlayer6", {
	arg out=0, bufnum=0, rate=1, rateLag=0,start=0, end=1, reset=0, t_trig=1,
	loops=1, amp=0.5, resetFreq=1, loopRate=1,loopRange=0.5,loopOffset=0.0;
	var snd,snd2,pos,pos2,frames,duration,env;
	var startA,endA,startB,endB,resetA,resetB,crossfade,aOrB,lfo1,lfo,lfo_trig;

	// THESE LINES ARE AMAZING
	// INSPIRED FROM the b-roll: https://www.youtube.com/watch?v=g6xdPRGHLLg
	lfo1=Phasor.kr(t_trig,2*pi*s.options.blockSize/s.sampleRate*resetFreq,0,2*pi)-0.1;
	lfo=(Phasor.kr(t_trig,2*pi*s.options.blockSize/s.sampleRate*loopRate,0,2*pi)-0.01;).sin;
	t_trig=Trig.kr(lfo1>0,0.01);
	reset=Clip.kr(LinLin.kr(lfo*loopRange,-1,1,0,1)+loopOffset-0.5).poll;

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


	SendTrig.kr(t_trig,0,pos/frames);
	Out.ar(out,LPF.ar((crossfade*snd)+((1-crossfade)*snd2) * env * amp,MouseX.kr(20,20000,1)))
}).add;
o = OSCFunc({ arg msg, time;
    [time, msg].postln;
	NetAddr("localhost", 12345).sendMsg('/pos',msg[3]);
},'/tr', s.addr);
)

~buffer=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/everything.flac");
x=Synth("samplePlayer6", [\bufnum, ~buffer]); // will start playing
// try different combos...
x.set(\t_trig,1,\resetFreq,4,\loopRate,2.5,\loopRange,0.01,\loopOffset,0.03)
x.set(\t_trig,1,\resetFreq,172/60*2,\loopRate,172/60/4*2.5,\loopRange,0.01,\loopOffset,0.03)
x.set(\t_trig,1,\resetFreq,172/60*2,\loopRate,172/60/2*2.5,\loopRange,0.03,\loopOffset,0.12)
x.set(\t_trig,1,\resetFreq,172/60*2,\loopRate,172/60/2*2.5,\loopRange,0.035,\loopOffset,0.26)
x.set(\t_trig,1,\resetFreq,172/60*2,\loopRate,172/60/4*2.5,\loopRange,0.035,\loopOffset,0.41)
x.set(\t_trig,1,\resetFreq,2,\loopRate,0.8,\loopRange,0.02,\loopOffset,0.13)
x.set(\t_trig,1,\resetFreq,4,\loopRate,2.5,\loopRange,0.05,\loopOffset,0.1)
x.set(\t_trig,1,\resetFreq,1,\loopRate,0.25,\loopRange,0.05,\loopOffset,0.3)
x.set(\t_trig,1,\resetFreq,2,\loopRate,0.25,\loopRange,0.07,\loopOffset,0.6)
x.set(\t_trig,1,\resetFreq,1,\loopRate,2.5,\loopRange,0.1,\loopOffset,0.09)

