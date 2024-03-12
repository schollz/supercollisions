
(
c=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/beats16_bpm150_Ultimate_Jack_Loops_014__BPM_150_.wav");
)




(
c=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/pad_bpm120_beats64.wav");
)



(
{
	[EnvGen.kr(Env.new([1,0.1,1,1],[60/120,60/120,60/120,60/120]*4,\lin,2,0),1,timeScale:0.01),
		EnvGen.kr(Env.new([1,0.1,1,1],[60/120,60/120,60/120,60/120]*4,\sine,2,0),1,timeScale:0.01),
		EnvGen.kr(Env.new([1,0.1,1,1],[60/120,60/120,60/120,60/120]*4,\exponential,2,0),1,timeScale:0.01)]
}.plot(0.035);
)


(
x=SynthDef("tapestop",{
	arg out=0,bufnum=0;
	var tape_env=EnvGen.kr(Env.new([1,0.047,1],[LFNoise0.kr(1).range(0.75,1.5)*2,LFNoise0.kr(1).range(0.25,0.75)],\exponential,releaseNode:1).poll,MouseX.kr()>0.5); // \sine \lin \exponential
	var snd=PlayBuf.ar(2,bufnum,tape_env,loop:1);
	snd=snd*Lag.kr(tape_env>0.04701);
	snd = snd * EnvGen.ar(Env.new([0,1],[1]));
	// tape-esque sounds
	snd = AnalogTape.ar(snd,0.9,0.9,0.9,2);
	snd = AnalogChew.ar(snd,0.1);
	snd = AnalogDegrade.ar(snd,0.05,0.1,0.6);
	snd = AnalogLoss.ar(snd,0.8);
	Out.ar(out,snd);
}).play(s, [\out, 0, \bufnum, c.bufnum]);
)


x.set(\amp,1.0);
x.set(\amp,0.7,\t_trig,1);
x.set(\bpm,120);
s.peakCPU;


(
{
	EnvGen.kr(Env.new([1,0.047,1],[LFNoise0.kr(1).range(0.75,1.5),LFNoise0.kr(1).range(0.25,0.75)],\exponential,releaseNode:1),1)
}.plot(2)
)
(
{
	1-EnvGen.kr(Env.new([1,0,1,1],[60/120,60/120,60/120,60/120]*4,[\lin,\lin,\lin,\lin],2,0),1,timeScale:0.01)
}.plot(0.2);
)

(
{
	EnvGen.kr(Env.circle([0,1], [60/120-(60/120/8),(60/120/8)]/4, curve: 'sine'));
}.plot(1)
)