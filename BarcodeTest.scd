(
s.waitForBoot({
	Routine {
		SynthDef("effects",{
			var snd=In.ar(0,2);
			var snd2=snd*VarLag.kr(LFNoise0.kr(4),1/4,warp:\sine).range(1,4);
			snd2=AnalogTape.ar(snd2,0.9,0.9,0.7);
			snd2=AnalogChew.ar(snd2,VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1),Trig.kr(Dust.kr(0.5),LFNoise0.kr(1).range(0.5,1.8)),VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1));
			snd2=AnalogDegrade.ar(snd2,Trig.kr(Dust.kr(0.5),LFNoise0.kr(1).range(0.1,0.3)),Trig.kr(Dust.kr(0.5),LFNoise0.kr(1).range(0.1,0.3)),VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1),VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1));
			snd2=AnalogLoss.ar(snd2,VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1),VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1),VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1),VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1));
			snd2=snd2.tanh*0.7;
			snd2=HPF.ar(snd2,120);
			snd2=BPeakEQ.ar(snd2,330,1,-3);
			snd2=BPeakEQ.ar(snd2,660,1,-3);
			snd2=SelectX.ar(0.15,[snd2,Fverb.ar(snd2[0],snd2[1],50)]);
			ReplaceOut.ar(0,snd2);
		}).send(s);
		s.sync;
		x=Synth.tail(s,"effects");
		b=Barcode.new(Server.default);
		b.load(1,"/home/zns/Documents/supercollisions/mahler2.wav");
		s.sync;
		b.play(1,1,1,1);
		b.play(1,2,0.5,1.5);
		b.play(1,3,2,0.25);
		b.play(1,4,0.25,2);
		// b.play(1,5,4,0.125);
	}.play;
});
)
