(
{
	arg note=32;
	var snd;
	var detune=MouseX.kr(0,2);
	snd = SinOsc.ar((note+12).midicps+detune);
	snd = snd + SinOsc.ar((note+12).midicps-detune);
	
	snd = Splay.ar(snd);
	snd = RHPF.ar(snd,(note+12).midicps,0.7);
	snd = snd + SinOsc.ar((note).midicps!2);
	snd = (snd*MouseY.kr(0.1,2)).tanh.softclip;
	snd = Compander.ar(snd,snd);
	Out.ar(0,snd);
}.play;
)

(
{
	arg note=36;
	var snd;
	var detune=MouseX.kr(0,2);
	snd = SinOsc.ar((note+12).midicps+detune);
	snd = snd + SinOsc.ar((note+12).midicps-detune);
	
	snd = Splay.ar(snd);
	snd = RHPF.ar(snd,(note+12).midicps,0.7);
	snd = snd + SinOsc.ar((note).midicps!2);
	snd = (snd*MouseY.kr(0.1,2)).tanh.softclip;
	//snd = Compander.ar(snd,snd);
	Out.ar(0,snd);
}.play;
)