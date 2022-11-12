b = Buffer.alloc(s,44100*6,2);
c = Buffer.alloc(s,44100*6,2);
b = Buffer.allocConsecutive(2,s,44100*10,1);
c = Buffer.allocConsecutive(2,s,44100*10,1);

(
SynthDef("sine",{
	arg freq=440,buf,delay=1,decay=1;
	var snd=Saw.ar([freq,freq+2])*EnvGen.ar(Env.perc(0.01,0.5))*0.1;
	snd=snd+Mix.fill(6,{|n|
		BufDelayN.ar(buf,snd,((n+1)*delay),1/(Clip.kr(decay+1,1,4)**n));
	});
	DetectSilence.ar(snd,0.0001,2,doneAction:2);
	Out.ar(0,snd);
}).add;
)
2.mod(2)
b.clear;
Synth("sine",[freq:440,buf:b,delay:0.5,decay:1])
c
Synth("sine",[freq:880,buf:c,delay:0.3,decay:1])
c