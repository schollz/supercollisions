(
{
	arg hz=170,amp=0.5;

	var snd,fx,y,z,note;

	// hz = TChoose.kr(Dust.kr(0.1),[hz,hz*1.5]);

	note=hz.cpsmidi;

	snd=Pan2.ar(Pulse.ar((note-12).midicps,LinLin.kr(LFTri.kr(0.5),-1,1,0.2,0.8),0.8));
	// ADD LPF to bass
	snd=MoogLadder.ar(snd,LinExp.kr(VarLag.kr(LFNoise0.kr(1/6),6,warp:\sine),-1,1,hz*2,hz*4));


	snd=snd + Mix.ar({

		var osc1,osc2,env,snd,mod1,note2;



		osc1=LFTri.kr(rrand(1/100,1/30),rrand(0,pi)).range(0,2).floor;

		osc2=LFTri.kr(rrand(1/100,1/30),rrand(0,pi)).range(0,2).floor;

		// ADD RANDOM LAG TO THINGS
		note2=Lag.kr((note+(TChoose.kr(Impulse.kr(0.2),[4,7]) * osc1) + (TChoose.kr(Impulse.kr(0.05),[0,5]) * osc2)).midicps,Rand(1,20)/10);


		snd=SawDPW.ar(note2);

		// low pass filter
		snd=MoogFF.ar(snd,LinExp.kr( VarLag.kr(LFNoise0.kr(1/3),3,warp:\sine),-1,1,200,10000));
		// high pass filter
		snd=HPF.ar(snd,LinExp.kr( VarLag.kr(LFNoise0.kr(1/3),3,warp:\sine),-1,1,20,10000));

		// modulate amplitude of each oscillator
		snd=snd*VarLag.kr(LFNoise0.kr(0.1),1/0.1,warp:\sine);

		snd=DelayC.ar(snd, rrand(0.01,0.1), LFNoise1.kr( Rand(5,10), 0.001, 0.1)/Rand(10,20) );

		Pan2.ar(snd,VarLag.kr(LFNoise0.kr(1/3),3,warp:\sine))
	}!10);

	snd=MoogLadder.ar(snd.tanh,LinExp.kr(VarLag.kr(LFNoise0.kr(1/6),6,warp:\sine),-1,1,hz*10,hz*120));

	// reverb predelay time :
	z = DelayN.ar(snd, 0.1);

	// 7 length modulated comb delays in parallel :
	y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.1, LFNoise1.kr(0.1.rand, 0.04, 0.05), 15) }));

	// two parallel chains of 4 allpass delays (8 total) :
	4.do({ y = AllpassN.ar(y, 0.050, [0.050.rand, 0.050.rand], 1) });

	// add original sound to reverb and play it :
	snd=snd+(0.1*y);

	snd=HPF.ar(snd*amp,20);

	snd=snd*EnvGen.ar(Env.new([0,1],[4]));

	Out.ar(0,snd.tanh*(-10.dbamp));
}.play
)

(
{
	{
		rrand(0.1,0.2).poll;
	}!4
}.play
)