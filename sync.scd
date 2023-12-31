(
s.waitForBoot({
	b = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/1.flac");
	SynthDef("coolsynth",{
		arg buf,note=60;
		var snd,sndamp,sndcapture,osc;
		var mod;
		snd = PlayBuf.ar(2,buf,loop:2);
		sndamp = Amplitude.ar(snd);
		osc = SinOsc.ar(note.midicps,Lag.ar(Latch.ar(snd,Impulse.kr(MouseX.kr(1,1000))).mod(3.14)));
		Out.ar(snd,osc);
		// Out.ar(0,osc);
	}).add;
	s.sync;
	Synth.head(s,"coolsynth",[\buf,b]);
});
)



(
s.waitForBoot({
	b = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/hem.wav");
	SynthDef("coolsynth",{
		arg buf,note=60;
		var snd;
		snd = PlayBuf.ar(2,buf,
			rate:BufRateScale.ir(buf),
			trigger:Impulse.kr(0),
			startPos:s.sampleRate*10,
			loop:2
		);
		snd = (snd*MouseX.kr(1,200)).tanh;
		// snd = (snd*100).distort;
		// snd = (snd*100).softclip;
		// snd = CrossoverDistortion.ar(snd,100);
		snd = snd / 10;
		Out.ar(0,snd);
	}).add;
	s.sync;
	Synth.head(s,"coolsynth",[\buf,b]);
});
)


{[SinOsc.ar(100,mul:5).tanh,SinOsc.ar(100,mul:5).softclip,SinOsc.ar(100,mul:5).distort]}.plot(1/100)

(
{BPF.ar(WhiteNoise.ar(1),440,MouseX.kr(0.1,1))}.play;

b.plot
