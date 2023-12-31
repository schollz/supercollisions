// don't let the devil
(
SynthDef("killer",{
	arg note = 28;
	var snd;
	snd = LinPan2.ar(SinOsc.ar(note.midicps,0,-4.dbamp),-1);
	
	snd = snd + LinPan2.ar(SinOsc.ar(note.midicps,0,-4.dbamp),1);
	snd = snd + LinPan2.ar(SinOsc.ar([note+12].midicps,0,-20.dbamp),-0.33);
	snd = snd + LinPan2.ar(SinOsc.ar([note+19].midicps,0,-23.dbamp),0.33);
	snd = snd * EnvGen.ar(Env.perc(0.05,15),\t_trig.kr(1));
	Out.ar(0,snd*6.neg.dbamp*((24-note)/2).dbamp);
}).play;
)
