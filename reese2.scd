
(
{
	arg note=32,detune=0.15,spread=0.7;
	var freq=(note+(detune*[-0.97,-0.313,0,0.374,0.87])).midicps;
	var snd=SawDPW.ar(freq);
	snd=snd+SinOsc.ar(note.midicps+1,mul:0.5);
	snd = Splay.ar(snd,spread);
	snd = BLowPass4.ar(snd,note.midicps*8,0.8);
	snd = snd * EnvGen.ar(Env.perc(0.1,2));
	Out.ar(0,snd*(-12.dbamp));
}.play
)