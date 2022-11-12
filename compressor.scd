// from ezra
// https://github.com/norns-study-group/pirate-radio/blob/main/supercollider/classes/PirateRadio.sc#L803-L814
(
var n, mu, unit;
n = 512*2;
~mu = 255*2;
~unit = Array.fill(n, {|i| i.linlin(0, n-1, -1, 1) });
~compressCurve = ~unit.collect({ |x|
	x.sign * log(1 + ~mu * x.abs) / log(1 + ~mu);
});
~expandCurve = ~unit.collect({ |y|
	y.sign / ~mu * ((1+~mu)**(y.abs) - 1);
});
)

(
~compressBuf = Buffer.loadCollection(s,Signal.newFrom(~compressCurve).asWavetableNoWrap);
~expandBuf = Buffer.loadCollection(s, Signal.newFrom(~expandCurve).asWavetableNoWrap);
b = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/beats16_bpm150_Ultimate_Jack_Loops_014__BPM_150_.wav"); // remember to free the buffer later.
b = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sd002.wav"); // remember to free the buffer later.
c = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/kick000.wav"); // remember to free the buffer later.
)
(
SynthDef("player", {| out = 0, bufnum = 0 |
	var steps = 256, compAmt=1, expAmt=1;
	var src, comp, x, crush, exp;
	var snd,env,pulse;
	var duration=TChoose.kr(Impulse.kr(1),[2,4,4,6,6,6,8,8,8,8]);
	pulse=Impulse.kr(duration);
	env=EnvGen.ar(Env.perc(0.01,TRand.kr(1/duration,4/duration,pulse)),pulse);
	src=PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum),pulse,TExpRand.kr(0.0001,0.1,pulse)*BufFrames.kr(bufnum));
	// src=HPF.ar(src,200);
	// src = SelectX.ar(MouseX.kr(), [src, Shaper.ar(~compressBuf.bufnum, src)]);
	// src = SelectX.ar(MouseY.kr(), [src, Shaper.ar(~expandBuf.bufnum, src)]);
	// src = src*MouseX.kr();
	//src=Compander.ar(src,src);
	Out.ar(out,src*env*TExpRand.kr(0.5,1.0,pulse)*0.7)
}).play(s, [\out, 0, \bufnum, b]);
SynthDef("player", {| out = 0, bufnum = 0 |
	var steps = 256, compAmt=1, expAmt=1;
	var src, comp, x, crush, exp;
	var snd,env,pulse;
	pulse=Impulse.kr(2);
	env=EnvGen.ar(Env.perc(0.01,TRand.kr(1/2,4/2,pulse)),pulse);
	src=PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum),pulse,TExpRand.kr(0.0001,0.05,pulse)*BufFrames.kr(bufnum));
	// src=LPF.ar(src,800);
	// src = SelectX.ar(MouseX.kr(), [src, Shaper.ar(~compressBuf.bufnum, src)]);
	// src = SelectX.ar(MouseY.kr(), [src, Shaper.ar(~expandBuf.bufnum, src)]);
	// src = src*MouseX.kr();
	src=Compander.ar(src,src,0.1);
	Out.ar(out,src*env*TExpRand.kr(0.8,2.5,pulse))
}).play(s, [\out, 0, \bufnum, c]);
)