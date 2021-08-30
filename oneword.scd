(
Routine {
	SynthDef("oneWordDelay",{
		arg in,out;
		var snd,gate,sndDelay;
		snd=In.ar(in,1);
		// one word ping pong delay
		gate=Lag.ar(DetectSilence.ar(snd,amp:0.01,time:0.05,doneAction:0),0.1);
		sndDelay=CombC.ar(snd,1.0,1.0,5)*0.25;
		sndDelay=Pan2.ar(sndDelay,SinOsc.kr(1.0));
		snd=SelectX.ar(gate,[snd,sndDelay]);
		Out.ar(out,snd);
	}).add;
	s.sync;

	SynthDef("simplePlayer",{
		arg out,buf;
		var snd;
		snd=PlayBuf.ar(1,buf);
		Out.ar(out,snd);
	}).add;
	s.sync;


	~delayBus = Bus.audio(s,1);
	s.sync;
	b = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/goalltheway.wav");
	s.sync;

	~player=Synth.new("simplePlayer",[\out,~delayBus,\buf,b]);
	s.sync;
	~oneWordDelay=Synth.after(~player,"oneWordDelay",[\out,0,\in,~delayBus]);
	s.sync;

}.play;
)

s.record