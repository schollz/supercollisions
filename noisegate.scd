(
b = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/1.flac"); //
)

(
SynthDef("noisegate",{
	arg             noise_gate_db=60.neg,noise_gate_attack=0.01,noise_gate_release=0.01;
	var snd=PlayBuf.ar(2,b,loop:1);
	var snd_db=Amplitude.ar(snd).ampdb;
	var snd_db_max=RunningMax.kr(snd_db,Impulse.kr(1));
	var snd_db_thresh=VarLag.kr(LFNoise0.kr(1/3),3,warp:\sine).range(24.neg,1.neg);

	snd = snd * EnvGen.ar(Env.asr(noise_gate_attack,1,noise_gate_release),snd_db>(snd_db_max+snd_db_thresh));

	// snd=Compander.ar(snd,Pulse.ar(25),MouseX.kr(32.neg,12).dbamp,10,1,0.01,0.01); // compressor noise gate
	Out.ar(0,snd);
}).play(s);
)



(
{
	var snd=PlayBuf.ar(2,b,loop:1);
	var env=LFTri.ar(2,width:0.5)!2>0;
	env=CDSkip.ar(env,autoMode:1,autoSpeed:10);
	env=(env<0.001) + ((env>0.001)*env);
	Out.ar(0,snd*env);
}.play;
)