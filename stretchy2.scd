(
s.waitForBoot({
    SynthDef("stretch",{
        arg buf,pos=0.3,xfade=0.05,slowdown=4,windowSeconds=0.1;
        var windowSelect,window,window1,window2,windowStart,windowTrig;
        var snd,snd1,snd2;
        var frames=BufFrames.ir(buf);
        var windowFrames=(s.sampleRate*windowSeconds).round;
        var playRate=BufRateScale.ir(buf);
        var phase = Phasor.ar(
			rate: playRate/8,
            start:pos*frames,
            end:48000000,
        );
		phase=DC.ar(frames)*MouseX.kr();
		windowFrames=(MouseY.kr(0.0005,2)*windowFrames);
		windowTrig=Trig.ar(LocalIn.ar(1))+Changed.ar(phase,100);
        windowStart=Gate.ar(phase,windowTrig);
        windowSelect=ToggleFF.ar(windowTrig);
        window1=Phasor.ar(
            trig: 1-windowSelect,
            rate: playRate,
            start: 0,
            end: 48000000,
            resetPos: phase,
        );
        window2=Phasor.ar(
            trig: windowSelect,
            rate: playRate,
            start: 0,
            end: 48000000,
            resetPos: phase,
        );
        window=Select.ar(windowSelect,[window1,window2]).poll;
		LocalOut.ar(
			(window>(windowStart+windowFrames))
		);
		snd1=BufRd.ar(2,buf,window1.mod(frames),1,4);
		snd2=BufRd.ar(2,buf,window2.mod(frames),1,4);
        snd=SelectX.ar(Lag.ar(windowSelect,xfade),[snd1,snd2]);
        Out.ar(0,snd);
    }).send(s);
    s.sync;
    b=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/mahler.wav");
    s.sync;
    Synth("stretch",[\buf,b]);
});
)


(
{
	arg pos=0;
	var windowSelect,window,window1,window2,windowStart,windowTrig;
	var frames=88000;
	var windowFrames=5000;
	var playRate=1;
	var phase = Phasor.ar(
		rate: playRate/4,
		start:pos*frames,
		end:frames,
	);
	phase=DC.ar(MouseX.kr());
	windowTrig=LocalIn.ar(1);
	windowStart=Gate.ar(phase,windowTrig);
	windowSelect=ToggleFF.ar(windowTrig);
	window1=Phasor.ar(
		trig: 1-windowSelect,
		rate: playRate,
		start: 0,
		end: frames,
		resetPos: phase,
	);
	window2=Phasor.ar(
		trig: windowSelect,
		rate: playRate,
		start: 0,
		end: frames,
		resetPos: phase,
	);
	window=Select.ar(windowSelect,[window1,window2]);
	LocalOut.ar(window>(windowStart+windowFrames));
	[phase,windowStart,windowSelect*20000,window1,window2,window]
}.plot(1)
)