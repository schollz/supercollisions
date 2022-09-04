(
SynthDef(\belllike,{
	arg out=0, freq=330, impdecay=0.01, attack=0.0001;
	var snd, trig, decay;
	var sustain=1.5;
	var amp=0.01;
	trig = Impulse.ar(0);
	decay = Decay2.ar(trig, attack, impdecay) * 1;
	snd = Ringz.ar(decay, freq*[1,1.01], sustain);
	snd = snd + Ringz.ar(decay, freq*[2.01,2.0], sustain,0.4);
	snd = snd + Ringz.ar(decay, freq*[4.01,4.0], sustain,0.2);
	snd = snd+(Klank.ar(`[[freq,freq*2,freq*1.5,freq*1.75],nil,[1,0.5,0.25,0.5]],WhiteNoise.ar(0.1))*EnvGen.ar(Env.perc(attack,sustain))*0.2);
	snd = LPF.ar(snd,freq*2);
	snd = HPF.ar(snd,80);
	DetectSilence.ar(snd,doneAction:2);
	snd = snd * amp;
	Out.ar(out, snd);
}).add;
)


Pbind(\instrument, \belllike, \freq, Pseq(([60,62,65,60,62,65,60,62,65,60,62,65,58,62,67,58,62,67,58,62,67,58,62,67]+12).midicps, inf), \dur, Pseq([0.2],inf)).play;
