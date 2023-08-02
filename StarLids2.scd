150.cpsmidi

(
// s.record;
b=Buffer.alloc(s,s.sampleRate*120,2);
{
	arg hz=550,amp=1;
	var snd,fx;
	var snd2,pos,pos2;
	// convert hertz into midi notes
	var note=hz.cpsmidi;
	note = Lag.kr(Demand.kr(Dust.kr(1/7)+Impulse.kr(0),0,Dseq([50,50,50,50,50,50,50-7,50-7,50-7,50-7,50+5,50+5,50+5,50+5,50+5,50+5,50+5,50+5,50+5,50+5,50+5],inf)),0.1)+0;
	// PWM suboscillator
	snd=Pan2.ar(Pulse.ar((note-12).midicps,LinLin.kr(LFTri.kr(0.5),-1,1,0.2,0.8))/12*amp);
	// mix in 12 other oscillators (#12 is arbitary)
	snd=snd+Mix.ar({
		var osc1,osc2,osc3,env,snd;
		// osc1+osc2 control the interval
		osc1=LFTri.kr(rrand(1/120,1/60),rrand(0,2*pi)).range(0,2).floor;
		osc2=LFTri.kr(rrand(1/120,1/60),rrand(0,2*pi)).range(0,2).floor;
		osc3=LFTri.kr(rrand(1/120,1/50),rrand(0,2*pi)).range(0,2).floor;
		// define sawtooth oscillator with pitch oscillating between +0, +4, +5, and +9 semitones
		// those define intervals of a major third, major fourth and major sixth relative to root
		snd=SawDPW.ar((note+(4*osc1)+(5*osc2)+(12*osc3)+Rand(-0.05,0.05)).midicps);
		// each oscillator goes in and out according to a randomly oscillating LPF
		snd=LPF.ar(snd,LinExp.kr(SinOsc.kr(rrand(1/30,1/10),rrand(0,2*pi)),-1,1,20,12000));
		// each oscillator has a small delay which serves as a chorus effect
		snd=DelayC.ar(snd, rrand(0.01,0.03), LFNoise1.kr(Rand(5,10),0.01,0.02)/15 );
		// each oscillate indepedently oscillates in stereo field
		Pan2.ar(snd,VarLag.kr(LFNoise0.kr(1/3),3,warp:\sine))/12*amp
	}!18);
	// cut out low frequencies
	snd=HPF.ar(snd,20);
	Amplitude.kr(Mix.ar(HPF.ar(snd,2000)),1,1).ampdb.poll;

	pos=Phasor.ar(1,1,0,BufFrames.ir(b));
	pos2=Phasor.ar(1,VarLag.kr(LFNoise0.kr(4),1/4,warp:\sine).range(VarLag.kr(LFNoise0.kr(4),1/4,warp:\sine).range(0.98,1.0),VarLag.kr(LFNoise0.kr(4),1/4,warp:\sine).range(1.00,1.005)),0,BufFrames.ir(b));
	BufWr.ar(snd,b,pos);
	snd=BufRd.ar(2,b,(pos2-10).mod(BufFrames.ir(b)),1,4);
	snd=snd*VarLag.kr(LFNoise0.kr(4),1/4,warp:\sine).range(1,1.2);
	snd=AnalogTape.ar(snd,0.9,0.9,1.1,oversample:4);
	snd=snd+(0.1*AnalogVintageDistortion.ar(snd,0.01,0.5,oversample:2));
	snd=SelectX.ar(MouseX.kr(),[snd,AnalogChew.ar(snd,VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1),Trig.kr(Dust.kr(0.5),LFNoise0.kr(1).range(0.5,1.8)),VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1))]);
	snd=SelectX.ar(LFNoise2.kr(1/7),[snd,
		AnalogDegrade.ar(snd,Trig.kr(Dust.kr(0.5),LFNoise0.kr(1).range(0.1,0.3)),Trig.kr(Dust.kr(0.5),LFNoise0.kr(1).range(0.1,0.3)),VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1),VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1))
	]);
	snd=SelectX.ar(LFNoise2.kr(1/7),[snd,
		AnalogLoss.ar(snd,VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1),VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1),VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1),VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1))
	]);
	// snd=snd.tanh*0.7;

	snd2 = DelayN.ar(snd, 0.03, 0.03);
	snd2 = snd2 + PitchShift.ar(snd, 0.13, 2,0,1,1/3*1/2);
	snd2 = snd2 + PitchShift.ar(snd, 0.1, 4,0,1,0.5*1/3/2);
	snd2 = snd2 + PitchShift.ar(snd, 0.1, 8,0,1,0.125*1/3/2);
	snd2 = Fverb.ar(snd2[0],snd2[1],
		predelay: 20,
		input_amount: 100,
		input_lowpass_cutoff: 10000,
		input_highpass_cutoff: 100,
		input_diffusion_1: 75,
		input_diffusion_2: 62.5,
		tail_density: 70,
		decay: 60,
		damping: 5500,
		modulator_frequency: 1,
		modulator_depth: 0.1,
	);
	Out.ar(0,SelectX.ar(LFNoise2.kr(1/7),[snd,snd2])*EnvGen.ar(Env.new([0,1,1,0],[5,10000,1])));
}.play;
)