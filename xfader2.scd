(
s.waitForBoot({
	Routine {
		b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
		SynthDef("play",{
			arg buf,t_loop=0,loopSamples=8820,loopXFade=8820;

			var pos,sndMain,snd,pos0,pos1,posSwitch;
			var snd0,snd1,snd01,trig0=0,trig1=0,loopStart,loopEnd,loopThresh;
			var samplesTotal=BufSamples.ir(buf);
			pos=Phasor.ar(end:BufSamples.ir(buf));
			sndMain=BufRd.ar(1,buf,pos);

			loopStart=Latch.ar(pos-loopSamples-loopXFade,t_loop);
			loopThresh=Latch.ar(pos-loopXFade,t_loop);

			posSwitch=Phasor.ar(1,end:loopSamples);
			trig0=ToggleFF.kr(posSwitch<256);
			trig1=1-trig0;
			pos0=Phasor.ar(trig0,end:loopSamples+loopXFade,rate:MouseX.kr()*2);
			pos1=Phasor.ar(trig1,end:loopSamples+loopXFade,rate:MouseX.kr()*2);

			snd0=BufRd.ar(1,buf,(pos0+loopStart).mod(samplesTotal));
			snd1=BufRd.ar(1,buf,(pos1+loopStart).mod(samplesTotal));

			[pos0,pos1,trig0,trig1].poll;
			snd01=SelectX.ar(Lag.kr(trig0),[snd1,snd0]);
			snd=SelectX.ar(Latch.ar(t_loop,Changed.kr(t_loop)),[sndMain,snd01]);

			Out.ar(0,snd);
		}).add;
		0.1.wait;
		x=Synth("play",[buf:b]);
		0.8.wait;
		x.set(\t_loop,1);

	}.play;
});
)

44100*0.24