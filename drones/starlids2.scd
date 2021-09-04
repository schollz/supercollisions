{
	arg hz=220,amp=0.5,seconds=60;
	var snd,fx,y,z,note;

	note=hz.cpsmidi;
	snd=Pan2.ar(Pulse.ar((note-12).midicps,LinLin.kr(LFTri.kr(0.5),-1,1,0.2,0.8)));
	snd=MoogLadder.ar(snd,hz*2)/6;

	snd=snd + Mix.ar({
		var osc1,osc2,osc3,env,snd,mod1,note2;

		osc1=LFTri.kr(Rand(1/100,1/30),Rand(0,pi)).range(0,2).floor;
		osc2=LFTri.kr(Rand(1/100,1/30),Rand(0,pi)).range(0,2).floor;
		osc3=LFTri.kr(Rand(1/100,1/30),Rand(0,pi)).range(0,2).floor;

		// ADD RANDOM LAG TO THINGS
		note2=Lag.kr((note+(TChoose.kr(Dust.kr(0.05),[4,7]) * osc1) + (TChoose.kr(Dust.kr(0.02),[12,5]) * osc2) + (TChoose.kr(Dust.kr(0.01),[-12,0]) * osc3) ).midicps,Rand(1,20)/10);

		// snd=SawDPW.ar(note2);
		snd=Pulse.ar(note2,LinLin.kr(LFTri.kr(Rand(0.1,1),Rand(0,2*pi)),-1,1,0.2,0.8));
		//snd=SinOscFB.ar(note2,LinLin.kr(LFTri.kr(Rand(0.01,0.4),Rand(0,2*pi)),-1,1,0.2,1.8));
		snd=LPF.ar(snd,(note*2).midicps);

		// low pass filter
		snd=MoogFF.ar(snd,LinExp.kr( VarLag.kr(LFNoise0.kr(1/3),3,warp:\sine),-1,1,100,10000));
		// high pass filter
		snd=HPF.ar(snd,LinExp.kr( VarLag.kr(LFNoise0.kr(1/3),3,warp:\sine),-1,1,20,10000));

		// modulate amplitude of each oscillator
		snd=snd*VarLag.kr(LFNoise0.kr(0.1),1/0.1,warp:\sine);

		snd=DelayC.ar(snd, rrand(0.01,0.1), LFNoise1.kr( Rand(5,10), 0.001, 0.1)/Rand(10,15) );

		Pan2.ar(snd,VarLag.kr(LFNoise0.kr(1/3),3,warp:\sine))/2
	}!7);

	snd=MoogLadder.ar(snd.tanh,LinExp.kr(VarLag.kr(LFNoise0.kr(1/6),6,warp:\sine),-1,1,hz*10,hz*120));

	snd=snd*EnvGen.ar(Env.new([0,1,1,0],[4,seconds,4]));

	// reverb predelay time :
	z = DelayN.ar(snd, 0.04);
	// 7 length modulated comb delays in parallel :
	y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.1, LFNoise1.kr(0.1.rand, 0.04, 0.05), 15) }));
	// two parallel chains of 4 allpass delays (8 total) :
	4.do({ y = AllpassN.ar(y, 0.050, [0.050.rand, 0.050.rand], 1) });
	// add original sound to reverb and play it :
	snd=snd+(0.05*y);

	snd=HPF.ar(snd*amp,40);

	snd=snd*EnvGen.ar(Env.new([0,1,1,0],[4,seconds,16]));
	Out.ar(0,snd);
}.play;