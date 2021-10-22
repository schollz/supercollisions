// crossfading looper

b = Buffer.read(s, "/home/zns/Documents/supercollisions/beats16_bpm150_Ultimate_Jack_Loops_014__BPM_150_.wav"); // remember to free the buffer later.

(
SynthDef("xfadePlayer",{
	arg buf,xfade=1.6;
	var duration;
	var snd1,snd2,env1,env2,snd;
	var trig1,trig2;
	duration=BufDur.kr(buf);
	trig1=Impulse.kr(0.5/(duration-xfade));
	trig2=TDelay.kr(trig1,duration-xfade);
	env1=EnvGen.kr(Env.new([0,1,1,0],[xfade,duration-(2*xfade),xfade],[-0.5,4,0.5]),trig1);
	env2=EnvGen.kr(Env.new([0,1,1,0],[xfade,duration-(2*xfade),xfade],[-0.5,4,0.5]),trig2);

	BufDur.kr(buf);
	snd1 = env1*PlayBuf.ar(2,buf,BufRateScale.kr(buf),trig1);
	snd2 = env2*PlayBuf.ar(2,buf,BufRateScale.kr(buf),trig2);
	snd = snd1+snd2;
	Out.ar(0,snd);
}).play(s,[\buf,b,\xfade,60/150*4]);
)

60/150*4

(
{
	EnvGen.kr(Env.new([0,1,1,0],[0.1,0.2,0.1],[-0.5,4,0.5]),Impulse.kr(2))
}.plot(1)
)