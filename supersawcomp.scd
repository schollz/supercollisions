(
SynthDef("supersaw",{
	arg note;
	var input,mix,shift1, shift2, shift3, shift4, shift5, comp1,comp2, comp3, comp4, comp5, output;
	var snd;
	var freq = note.midicps;
	input = LFSaw.ar(freq);
	snd = {
		var shift = LFSaw.ar(Rand(2.1,7)*rrand(1,5)/10);
		var comp = input > shift;
		(input - comp) * LinLin.kr(note,36,90,0.5,1.1);
	}!2;
	snd = Mix.new(snd);
	snd = snd - input;
	snd = LeakDC.ar(snd*0.5);
	snd = RLPF.ar(snd,Clip.kr(MouseY.kr(1,30)*freq,100,20000),0.707);
	snd = snd * EnvGen.ar(Env.adsr(5,1,0.7,1));
	snd = Pan2.ar(snd,LFNoise2.kr(1/3,0.2));
	Out.ar(0,snd);

}).add;

SynthDef("out",{
	var snd = In.ar(0,2);
	snd = AnalogTape.ar(snd,0.6,0.6,0.7,1);
	snd = AnalogVintageDistortion.ar(snd*MouseX.kr(0.05,0.2),MouseX.kr(0.01,1,1),0.1,oversample:1);
	snd = SelectX.ar(LFNoise2.kr(1/3).range(0.5,0.9),[
		snd,
		Fverb.ar(snd[0],snd[1],
			predelay:100,
			tail_density:LFNoise2.kr(1/3).range(50,90),
			decay:LFNoise2.kr(1/3).range(50,90))
	]);
	ReplaceOut.ar(0,snd);
}).add;
)

(
var s = Server.default;
Synth.tail(s,"out");
Synth.head(s,"supersaw",[\note,60]);
x=Synth.head(s,"supersaw",[\note,67]);
Synth.head(s,"supersaw",[\note,69-12]);
Synth.head(s,"supersaw",[\note,36]);
Synth.head(s,"supersaw",[\note,48]);
)
x.set(\note,60)