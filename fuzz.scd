(
s.waitForBoot{
	Routine {
		var n, mu, unit, fuzzCurve;
		~bufs=Dictionary.new();
		n = 512*8;
		mu = 255*2;
		unit = Array.fill(n, {|i| i.linlin(0, n-1, -1, 1) });
		fuzzCurve = unit.collect({ |x|
			x / (1 + x.abs);
			// x.sign * log(1 + mu * x.abs) / log(1 + mu);
		});
		~bufs.put("fuzzBuf",Buffer.loadCollection(s,Signal.newFrom(fuzzCurve).asWavetableNoWrap));
		b=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/clean.wav",channels:[0]);
		// b=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/amenbreak_bpm136.wav",channels:[0]);
		// b=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/test1.wav_loop.1.wav",channels:[0]);
		SynthDef("fuzz",{
			arg buf,fuzzBuf,fuzzDrive,fuzzWet;
			var sndFuzz;
			var snd = PlayBuf.ar(1,buf,loop:1);
			// snd = snd + PinkNoise.ar(0.05);
			sndFuzz = snd * MouseY.kr(1,1000,1);
			snd=SelectX.ar(MouseX.kr(0,1),[snd*2,[sndFuzz,sndFuzz].tanh+BLowShelf.ar(Shaper.ar(fuzzBuf,(sndFuzz+Amplitude.ar(sndFuzz,mul:LFNoise2.kr(0.4!2).range(0.5,1)))),600,db:3)
			]);
			snd = LeakDC.ar(snd);
			snd = SelectX.ar(0.1,[snd,Fverb.ar(snd[0],snd[1])]);
			// snd = Pan2.ar(snd);
			Out.ar(0,snd*0.5);
		}).send(s);
		s.sync;
		Synth.head(s,"fuzz",[\buf,b,\fuzzBuf,~bufs.at("fuzzBuf")]);
	}.play;
}
)
~bufs.at("fuzzBuf").plot(separately:true);



(
SynthDef(\gabberkick, {
    var snd;
    snd = SinOsc.ar(Env([1000, 69, 40], [0.015, 0.1], \exp).ar * [-0.1, 0, 0.1].midiratio);
    snd = Mix(snd);
    snd = (snd * 10).tanh;
    snd = (snd * 5.1).atan;
    snd = BPeakEQ.ar(snd, XLine.kr(2000, 100, 0.3), 2.0, 8);
    snd = snd + DelayC.ar(snd, 0.01, SinOsc.ar(4).range(0.0, 0.001));
    snd = RLPF.ar(snd, 8000, 0.7);
    snd = snd * Env([0, 1, 0.7, 0.7, 0], [0.001, 0.01, 0.3, 0.02]).ar(2);
    snd = (snd * 0.6).clip(-1, 1);
    Out.ar(\out.kr(0), Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1)));
}).add;
)

Synth(\gabberkick, [amp: 0.6])