(
{
	arg hz=220,amp=0.5;
	var snd,mod,modFreq,sndk;
	modFreq=10;
	snd=[Mix.ar({
		var snd2;
		snd2=SelectX.ar(VarLag.kr(LFNoise0.kr(1/10),10,warp:\sine).range(0,1),[WhiteNoise.ar(),PinkNoise.ar()]);
		snd2=LPF.ar(snd2,LinExp.kr(VarLag.kr(LFNoise0.kr(1/10),10,warp:\sine),-1,1,20,20000));
		snd2=BPF.ar(snd2,hz,LinExp.kr(VarLag.kr(LFNoise0.kr(1/10),10,warp:\sine),-1,1,0.0001,0.02));
	}!16),Mix.ar({
		var snd2;
		snd2=SelectX.ar(VarLag.kr(LFNoise0.kr(1/10),10,warp:\sine).range(0,1),[WhiteNoise.ar(),PinkNoise.ar()]);
		snd2=LPF.ar(snd2,LinExp.kr(VarLag.kr(LFNoise0.kr(1/10),10,warp:\sine),-1,1,20,20000));
		snd2=BPF.ar(snd2,hz,LinExp.kr(VarLag.kr(LFNoise0.kr(1/10),10,warp:\sine),-1,1,0.0001,0.02));
	}!16)];
	snd=snd*100;

	snd=snd*EnvGen.ar(Env.new([0,1],[4]));
	Out.ar(0,snd.tanh*amp*(-10.dbamp));
}.play
)

{ DynKlank.ar(`[[800, 1071, 1153, 1723], nil, [1, 1, 1, 1]], Impulse.ar(2, 0, 0.1)) }.play;


{ DynKlank.ar(`[[200, 671, 1153, 1723], nil, [1, 1, 1, 1]], PinkNoise.ar([0.007, 0.007])) }.play;

(
{
	LinExp.kr(VarLag.kr(LFNoise0.kr(10),1/10,warp:\sine),-1,1,0.001,0.5)
}.plot(1)
)

(
{
	var modFreq=10;
	Clip.ar(LinExp.ar(LatoocarfianC.ar(modFreq*10,1,LFNoise2.kr(modFreq*10/20,1.5,1.5),LFNoise2.kr(modFreq*10/20,0.5,0.5),LFNoise2.kr(modFreq*10/20,0.5,0.5)).range(0,1),0,1,0.01,1),0.01,0.5);
}.plot(1)
)