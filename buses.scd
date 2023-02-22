s.boot;
(

SynthDef("a",{
	arg in,out;
	Out.ar(out,SinOsc.ar(440));
}).add;
SynthDef("b",{
	arg in,out;
	Out.ar(out,In.ar(in,1));
}).add;
)

(
Routine{
	~ab=Bus.audio(s,1);
	~bb=Bus.audio(s,1);
	~cb=Bus.audio(s,1);
	~db=Bus.audio(s,1);
	~eb=Bus.audio(s,1);
	s.sync;
	~a=Synth.head(s,"a",[\out,~ab]);
	s.sync;
	~b=Synth.after(~a,"b",[\in,~ab,\out,0]);
	s.sync;
}.play;
)


(
Routine{
	~b.free;
	~b=Synth.after(~a,"b",[\in,~ab,\out,~bb]);
	s.sync;
	~c=Synth.after(~b,"b",[\in,~bb,\out,0]);
	s.sync;
}.play;
)