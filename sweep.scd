// filter 
(
{
	var snd=WhiteNoise.ar(0.1)!2;
	snd=BPF.ar(snd,LinExp.kr(Line.kr(dur:1),0,1,100,6000),0.9);
	snd=RLPF.ar(snd,LinExp.kr(Line.kr(dur:1),0,1,100,6000),0.9);
	snd=snd*EnvGen.ar(Env.new([0,1,1,0],[0.01,1-0.02,0.01]),doneAction:2);
	Out.ar(0,snd);
}.play;
)
