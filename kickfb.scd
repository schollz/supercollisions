(
{
	arg amp=0.5,hz=200;
	var snd,pulse,pulseTrig;
	// var pulse=Impulse.kr(1);
	pulse=(SinOsc.kr(0.5)-SinOsc.kr(LFNoise0.kr(0.5).range(1,10)*0.5))>0;
	pulseTrig=Trig.kr(pulse);
	snd = Limiter.ar(SinOscFB.ar(EnvGen.kr(Env.new(levels:[0.1,hz,40],times:[0,0.1]),gate:pulseTrig),feedback:0.1,mul:pulseTrig),level:amp);
	snd = LPF.ar(snd.tanh,400);
	snd = HPF.ar(snd,20);
	Out.ar(0,snd.dup*amp);
}.play
)


(
{
	var hz=10;
	(SinOsc.kr(hz)-SinOsc.kr(hz*3))>0
}.plot(1)
)