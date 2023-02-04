(
s.waitForBoot({
	Routine{

		b = Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/bun.flac");
		1.wait;
		s.record;
		SynthDef("test",{
			var snd2;
			var snd=PlayBuf.ar(2,b,VarLag.kr(LFNoise0.kr(4),1/4,warp:\sine).range(VarLag.kr(LFNoise0.kr(4),1/4,warp:\sine).range(0.98,1.0),1.00),loop:1);
			snd2=snd*VarLag.kr(LFNoise0.kr(4),1/4,warp:\sine).range(1,4);
			snd2=AnalogTape.ar(snd2,0.9,0.9,0.7);
			snd2=AnalogChew.ar(snd2,VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1),Trig.kr(Dust.kr(0.5),LFNoise0.kr(1).range(0.5,1.8)),VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1));
			snd2=AnalogDegrade.ar(snd2,Trig.kr(Dust.kr(0.5),LFNoise0.kr(1).range(0.1,0.3)),Trig.kr(Dust.kr(0.5),LFNoise0.kr(1).range(0.1,0.3)),VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1),VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1));
			snd2=AnalogLoss.ar(snd2,VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1),VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1),VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1),VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1));
			snd2=snd2.tanh*0.7;
			snd2=HPF.ar(snd2,120);
			snd2=BPeakEQ.ar(snd2,330,1,-3);
			snd2=BPeakEQ.ar(snd2,660,1,-3);
			// snd2=LPF.ar(snd2,8000);
			Out.ar(0,snd2*EnvGen.ar(Env.new([0,1,1,0],[1,145,1],curve:\sine),doneAction:2));
		}).play;

	}.play;
});
)