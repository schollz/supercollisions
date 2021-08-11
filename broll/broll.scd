
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
	arg out=0, bufnum=0, rate=1, rateLag=0,start=0, end=1, reset=0, t_trig=1,videoID=0,
	loops=1, amp=0.5, resetFreq=1, loopRate=1,loopRange=0.5,loopOffset=0.0;
	var snd,snd2,pos,pos2,frames,duration,env;
	var startA,endA,startB,endB,resetA,resetB,crossfade,aOrB,lfo1,lfo,lfo_trig;

	// loopRange=MouseY.kr(0,0.2).poll;
	// loopOffset=MouseX.kr().poll;
	// THESE LINES ARE AMAZING
	// INSPIRED FROM the b-roll: https://www.youtube.com/watch?v=g6xdPRGHLLg
	lfo1=Phasor.kr(t_trig,2*pi*s.options.blockSize/s.sampleRate*resetFreq,0,2*pi)-0.1;
	lfo=(Phasor.kr(t_trig,2*pi*s.options.blockSize/s.sampleRate*loopRate,0,2*pi)-0.01;).sin;
	t_trig=Trig.kr(lfo1>0,0.01).poll;
	reset=Clip.kr(LinLin.kr(lfo*loopRange,-1,1,0,1)+loopOffset-0.5);

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


	SendTrig.kr(t_trig,videoID,reset);
	Out.ar(out,(crossfade*snd)+((1-crossfade)*snd2) * env * amp)
}).add;
o = OSCFunc({ arg msg, time;
    [time, msg].postln;
	NetAddr("localhost", 12345).sendMsg('/pos',~videos[msg[2]],msg[3]);
},'/tr', s.addr);
)

// Dmaj F#m Amaj...something like that
~videos=Array.new();

~videos=~videos.add("apollo.flac");
~buffer=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/"++~videos[~videos.size-1]);
x=Synth("samplePlayer6", [\bufnum, ~buffer,\videoID,~videos.size-1]);
x.set(\t_trig,1,\resetFreq,1,\loopRate,1.25,\loopRange,0.0002,\loopOffset,0.025)
x.set(\t_trig,1,\resetFreq,4,\loopRate,2.5,\loopRange,0.01,\loopOffset,0.98)
x.set(\t_trig,1,\resetFreq,4,\loopRate,2.5,\loopRange,0.0054,\loopOffset,0.972)
x.set(\t_trig,4,\resetFreq,4,\loopRate,2.5,\loopRange,0.012,\loopOffset,0.97)





~videos=~videos.add("stella.flac");
~stella=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/"++~videos[~videos.size-1]);
z=Synth("samplePlayer6", [\bufnum, ~stella,\videoID,~videos.size-1]);
z.set(\t_trig,1,\resetFreq,1,\loopRate,1,\loopRange,0.0002,\loopOffset,0.03,\amp,0.3)
z.set(\t_trig,1,\resetFreq,1,\loopRate,1.25,\loopRange,0.01,\loopOffset,0.180,\amp,1.0)



~videos=~videos.add("spoons.flac");
~spoons=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/"++~videos[~videos.size-1]);
y=Synth("samplePlayer6", [\bufnum, ~spoons,\videoID,~videos.size-1]);
y.set(\t_trig,1,\resetFreq,1,\loopRate,1.25,\loopRange,0.0002,\loopOffset,0.925,\amp,0.3)
y.set(\t_trig,1,\resetFreq,1,\loopRate,1.25,\loopRange,0.0001,\loopOffset,0.915,\amp,0.3)
y.set(\t_trig,1,\resetFreq,0.4,\loopRate,1.25,\loopRange,0.001,\loopOffset,0.875,\amp,1.0)
y.set(\t_trig,1,\resetFreq,1,\loopRate,1.25,\loopRange,0.005,\loopOffset,0.445,\amp,0.1)
y.set(\t_trig,1,\resetFreq,1,\loopRate,1.25,\loopRange,0.001,\loopOffset,0.84,\amp,0.3)
y.set(\t_trig,1,\resetFreq,1,\loopRate,1.25,\loopRange,0.004,\loopOffset,0.87,\amp,0.3)
y.set(\t_trig,1,\resetFreq,1,\loopRate,1.25,\loopRange,0.004,\loopOffset,0.97,\amp,0.2)
