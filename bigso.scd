(
s.options.memSize = 65536;
s.waitForBoot({

	SynthDef("hm", { arg note=50;
		var snd;
		var freq = [note-LFNoise2.kr(1/4).range(0.05,0.1),note+LFNoise2.kr(1/4).range(0.05,0.1)].midicps;
		var bassfreq = freq/2;
		snd = Pulse.ar(freq,SinOsc.kr([0.3,0.2]).range(0.3,0.7));
		snd = snd + Pulse.ar(freq*2.001,LFNoise1.ar(1/3).range(0.01,0.05),0.2);
		snd = snd + SinOsc.ar(bassfreq,0,1);
		snd = LeakDC.ar(snd);
		snd = snd.fold(-0.5,0.9);
		snd = LockhartWavefolder.ar(snd[0] * LFNoise1.kr(1/4).range(1,10), 4) + ((LockhartWavefolder.ar(snd[1] * LFNoise1.kr(1/4).range(1,10), 4)) * [-1,1]);
		snd = RLPF.ar(snd, LinExp.kr(LFNoise2.kr(1/4).range(0.01,1),0.01,1,200,4000),LFNoise2.kr(1/4).range(0.1,1));

		snd = AnalogVintageDistortion.ar(snd,0,1,0.1,0.1);
		snd = LeakDC.ar(snd);
		snd = snd.tanh * 0.8;
		snd = [LPF.ar(snd[0],
			LinExp.kr(LFNoise2.kr(1/4).range(0.01,1),0.01,1,2000,10000)),
		LPF.ar(snd[1],LinExp.kr(LFNoise2.kr(1/4).range(0.01,1),0.01,1,2000,10000))];
		//snd = snd + PitchShift.ar(snd,pitchRatio:2,mul:0.1);
		snd = SelectX.ar(MouseY.kr(),[snd,Fverb.ar(snd[0],snd[1],decay:70)]);
		snd = snd * SelectX.ar(MouseX.kr(),[DC.ar(1),SinOsc.ar(MouseX.kr(0.1,12)).range(0,1.5)]);
		Out.ar(0,snd);
	}).add;

});
)
Synth("hm",[\note,40]);

(
Synth("hm",[\note,40]);
Synth("hm",[\note,43]);
Synth("hm",[\note,47]);
)

x=Synth("hm",[\note,40]);
x=Synth("hm",[\note,40+12+7]);
x=Synth("hm",[\note,60-12]);