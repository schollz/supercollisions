(
b = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/kick000.wav"); //
)

b.play;
(
{
	|basefreq = 40, ratio = 4, sweeptime = 0.05, preamp = 1, amp = 1,
	decay1 = 0.9, decay1L = 0.3, decay2 = 0.3, clicky=0.0, out|
	var    fcurve = EnvGen.kr(Env([basefreq * ratio, basefreq], [sweeptime], \exp)),
	env = EnvGen.kr(Env([clicky,1, decay1L, 0], [0.0,decay1, decay2], -4), doneAction: Done.freeSelf),
	sig = SinOsc.ar(fcurve, 0.5pi, preamp).distort * env ;
	sig = Pan2.ar(sig);
	sig = sig.tanh;
	sig = SelectX.ar(0.3,[sig,Fverb.ar(sig[0],sig[1],10,90,2000,10,80,80,80,70,9000,1,0.1)]);
	sig = AnalogVintageDistortion.ar(sig,0.9,2,0.3,0.1,oversample:4);
	sig = sig*EnvGen.ar(Env.perc());
	Out.ar(out,sig);
}.play;
)