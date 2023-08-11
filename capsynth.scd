(
{
	var hz=MouseX.kr(20,60).midicps.poll;
	var capCharge = 0.005+(0.01*MouseY.kr(0,2));
	var mod=SinOsc.kr(SinOsc.kr(0.3).range(0.5,1.5)).range(0.25,0.75);
	var snd=EnvGen.ar(Env.perc(capCharge*mod,capCharge*(1-mod)),Impulse.ar([hz+0.1,hz-0.1]));
	snd = HPF.ar(snd,10);
	snd = LPF.ar(snd,400);
}.play
)

0.5/220