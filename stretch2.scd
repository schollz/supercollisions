(
s.waitForBoot({
	SynthDef("stretch",{
		arg buf,pos=0;
		var snd,window,windowStart,windowTrig;
	var frames=BufFrames.ir(buf);
	var playRate=BufRateScale.ir(buf);
	var phase = Phasor.ar(
		rate: playRate/8,
		start:pos*frames,
		end:frames,
	);
	windowTrig=LocalIn.ar(1);
	windowStart=Gate.ar(phase,windowTrig);
	window=Phasor.ar(
		trig: DelayL.ar(windowTrig,0.001,0.001),
		rate: playRate,
		start: 0,
		end: frames,
		resetPos: windowStart,
	);
	LocalOut.ar(Trig.ar(window>(windowStart+1100),0.001));
		snd=BufRd.ar(2,buf,window,1,4);
		Out.ar(0,snd);
	}).send(s);
	s.sync;
	a=Buffer.read(Server.default, thisProcess.nowExecutingPath.dirname++"/1.flac");
	s.sync;
	Synth("stretch",[\buf,a]);

});
)



a.play;

(
{
	arg buf,pos=0;
	var windowSelect,window,window1,window2,windowStart,windowTrig;
	var frames=BufFrames.ir(buf);
	var playRate=BufRateScale.ir(buf);
	var phase = Phasor.ar(
		rate: playRate/2,
		start:pos*frames,
		end:frames,
	);
	windowTrig=LocalIn.ar(1);
	windowStart=Gate.ar(phase,windowTrig);
	windowSelect=DelayN.ar(ToggleFF.ar(windowTrig),0.1);
	window1=Phasor.ar(
		trig: 1-windowSelect,
		rate: playRate,
		start: 0,
		end: frames,
		resetPos: windowStart,
	);
	window2=Phasor.ar(
		trig: windowSelect,
		rate: playRate,
		start: 0,
		end: frames,
		resetPos: windowStart,
	);
	window=Select.ar(windowSelect,[window1,window2]);
	LocalOut.ar(window>(windowStart+11000));
	[phase,windowStart,windowSelect*20000,window1,window2,window]
}.plot(1)
)
