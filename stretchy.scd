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
			rate: playRate/EnvGen.kr(Env.new([Rand(6,8),Rand(8,12)],[Rand(2,8)]),timeScale:1),
            start:pos.poll*frames,
            end:48000000,
        );
		windowFrames=EnvGen.kr(Env.new([Rand(0.2,0.8),Rand(0.5,2),Rand(0.05,0.1),Rand(2,5),Rand(0.02,0.05)],[Rand(0.05,0.3),Rand(1,3),Rand(0.5,2),Rand(1,3)]),timeScale:1)*windowFrames;
        windowTrig=LocalIn.ar(1);
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
        window=Select.ar(windowSelect,[window1,window2]);
		LocalOut.ar(
			((playRate>0)*(window>(windowStart+windowFrames)))+
			((playRate<0)*(window<(windowStart-windowFrames)))
		);
		snd1=BufRd.ar(2,buf,window1.mod(frames),1,4);
		snd2=BufRd.ar(2,buf,window2.mod(frames),1,4);
        snd=SelectX.ar(Lag.ar(windowSelect,xfade),[snd1,snd2]);
        Out.ar(0,snd);
    }).send(s);
    s.sync;
    b=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/amenbreak_bpm136.wav");
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