{
    arg hz=110,amp=0.5, seconds=60;
    var local, in, ampcheck,movement, sig, snd, y, z;

	in = Splay.ar(Pulse.ar(Lag.kr(hz*
		LinLin.kr(SinOsc.kr(LFNoise0.kr(1)/2),-1,1,0.99,1.01),1),
		LinLin.kr(SinOsc.kr(LFNoise0.kr(1)),-1,1,0.45,0.55)
	)!1)/1;
	in = Balance2.ar(in[0] ,in[1],SinOsc.kr(
		LinLin.kr(LFNoise0.kr(0.1),-1,1,0.05,0.2)
	)*0.1);

	// from tape example
	// https://depts.washington.edu/dxscdoc/Help/Classes/LocalOut.html
    ampcheck = Amplitude.kr(Mix.ar(in));
    in = in * (ampcheck > 0.02); // noise gate
    local = LocalIn.ar(2);
    local = OnePole.ar(local, 0.4);
    local = OnePole.ar(local, -0.08);
    local = Rotate2.ar(local[0], local[1],0.2);
	local = DelayN.ar(local, 0.3,
		VarLag.kr(LinLin.kr(LFNoise0.kr(0.1),-1,1,0.15,0.3),1/0.1,warp:\sine)
	);
    local = LeakDC.ar(local);
    local = ((local + in) * 1.25).softclip;

/*	local = LPF.ar(local,MouseX.kr(40,16000));
	LocalOut.ar(local*MouseY.kr(0.5,1.5));*/

	// for the drone
    local = LPF.ar(local,
		VarLag.kr(LinLin.kr(LFNoise0.kr(0.3),-1,1,ArrayMin.kr([hz,80]),16000),1/0.3,warp:\sine)
	);
	LocalOut.ar(local*
		VarLag.kr(LinLin.kr(LFNoise0.kr(2),-1,1,1.01,1.5),1/2,warp:\sine)
	);
	sig = Balance2.ar(local[0] * 0.2,local[1]*0.2,SinOsc.kr(
		LinLin.kr(LFNoise0.kr(0.1),-1,1,0.05,0.2)
	)*0.1)*amp;

	// reverb predelay time 
	snd=sig;
	snd=snd*EnvGen.ar(Env.new([0,1,1,0],[4,seconds-8,4]));
	z = DelayN.ar(snd, 0.04);
	// 7 length modulated comb delays in parallel :
	y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.1, LFNoise1.kr(0.1.rand, 0.04, 0.05), 15) }));
	// two parallel chains of 4 allpass delays (8 total) :
	4.do({ y = AllpassN.ar(y, 0.050, [0.050.rand, 0.050.rand], 1) });
	// add original sound to reverb and play it :
	snd=snd+(0.025*y);

	snd=snd*EnvGen.ar(Env.new([0,1,1,0],[4,seconds-8,8]));
	Out.ar(0,snd);
}.play;