(
s.waitForBoot({
	SynthDef("a",{
		arg hz=200,amp=0.5;

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
	snd=snd.tanh;
	snd=snd*amp/8;

		Out.ar(0,snd);
	}).send(s);
});
)

Synth.new("a")