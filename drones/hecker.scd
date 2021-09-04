{
	arg hz=220,amp=0.5, seconds=60;
	var snd,mod,modFreq,sndk,bass,basshz;
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
	snd=snd*50;

	basshz=hz;
	basshz=Select.kr(basshz>100,[basshz,basshz/2]);
	basshz=Select.kr(basshz>100,[basshz,basshz/2]);
	bass=Pulse.ar(basshz,width:SinOsc.kr(1/3).range(0.2,0.4));
	bass=bass+LPF.ar(WhiteNoise.ar(SinOsc.kr(1/rrand(3,4)).range(1,rrand(3,4))),2*basshz);
	bass = Pan2.ar(bass,LFTri.kr(1/6.12).range(-0.2,0.2));
	bass = HPF.ar(bass,20);
	bass = LPF.ar(bass,SinOsc.kr(0.1).range(2,5)*basshz);
	snd=snd+(SinOsc.kr(0.123).range(0.5,2)*bass);

	snd=snd*EnvGen.ar(Env.new([0,1,1,0],[4,seconds,16]));
	Out.ar(0,snd.tanh*amp*(-10.dbamp));
}.play;
