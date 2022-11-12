(
{
	arg hz=300,amp=1.0;
	var imp=Impulse.kr(1);
	var env=EnvGen.ar(Env.perc(0.01,LFNoise0.kr(1).range(0.1,2)),imp);
	var sin1=SinOsc.ar(145/220*hz);
	var sin2=SinOsc.ar(hz,sin1*0.28*2*pi);
	var snd=sin2*env;
	snd=Fold.ar(snd,-0.8,0.8);
	Out.ar(0,snd);
}.play;
)

145/220