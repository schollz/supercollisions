{
    arg hz=220,amp=0.5,seconds=60;
	var snd,fx,y,z;
	var note=hz.cpsmidi;
	snd=Pan2.ar(Pulse.ar((note-12).midicps,LinLin.kr(LFTri.kr(0.5),-1,1,0.2,0.8))/12*amp);
	snd=snd+Mix.ar({
		var osc1,osc2,env,snd;
		osc1=LFTri.kr(rrand(1/100,1/30),rrand(0,2*pi)).range(0,2).floor;
		osc2=LFTri.kr(rrand(1/100,1/30),rrand(0,2*pi)).range(0,2).floor;
		snd=SawDPW.ar((note+(4*osc1)+(5*osc2)).midicps);
		snd=LPF.ar(snd,LinExp.kr(SinOsc.kr(rrand(1/30,1/10),rrand(0,2*pi)),-1,1,20,12000));
		snd=DelayC.ar(snd, rrand(0.01,0.03), LFNoise1.kr(Rand(5,10),0.01,0.02)/15 );
		Pan2.ar(snd,VarLag.kr(LFNoise0.kr(1/3),3,warp:\sine))/12*amp
	}!12);
	snd=MoogLadder.ar(snd.tanh,LinExp.kr(VarLag.kr(LFNoise0.kr(1/6),6,warp:\sine),-1,1,hz*8,hz*60));

	// reverb predelay time :
	z = DelayN.ar(snd, 0.048);
	// 7 length modulated comb delays in parallel :
	y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.1, LFNoise1.kr(0.1.rand, 0.04, 0.05), 15) }));
	// two parallel chains of 4 allpass delays (8 total) :
	4.do({ y = AllpassN.ar(y, 0.050, [0.050.rand, 0.050.rand], 1) });
	// add original sound to reverb and play it :
	snd=snd+(0.05*y);

	snd=HPF.ar(snd,20);
	snd=snd*EnvGen.ar(Env.new([0,1,1,0],[4,seconds-8,4]));
	Out.ar(0,snd);
}.play;