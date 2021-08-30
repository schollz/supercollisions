// plot - Fig. 19 from // https://en.wikipedia.org/wiki/Phase_distortion_synthesis#Simulating_a_resonant_filter
(
{
	var freqBase=100;
	var freqRes=130;
	var pdbase=Impulse.ar(freqBase);
	var pd=Phasor.ar(pdbase,2*pi*freqBase/s.sampleRate,0,2*pi);
	var pdres=Phasor.ar(pdbase,2*pi*freqRes/s.sampleRate,0,2*pi);
	var pdi=LinLin.ar((2*pi-pd).max(0),0,2*pi,0,1);
	[pd/(2*pi),pdres/(2*pi),SinOsc.ar(0,pdres),pdi,Lag.ar(SinOsc.ar(0,pdres)*pdi,1/freqBase)];
}.plot(0.011)
)


(
Routine {
	SynthDef("casioish",{
		arg freq=220, amp=0.5;
		var freqBase=freq;
		var freqRes=SinOsc.kr(Rand(0.1,0.5),0).range(freqBase/2,freqBase*2);
		var pdbase=Impulse.ar(freqBase);
		var pd=Phasor.ar(pdbase,2*pi*freqBase/s.sampleRate,0,2pi);
		var pdres=Phasor.ar(pdbase,2*pi*freqRes/s.sampleRate,0,2pi);
		var pdi=LinLin.ar((2pi-pd).max(0),0,2pi,0,1);
		var snd=Lag.ar(SinOsc.ar(0,pdres)*pdi,1/freqBase).dup;
		// snd=Splay.ar(snd);
		// snd= Mix.fill(6, {
		// 	var maxdelaytime= rrand(0.01,0.03);
		// 	var half= maxdelaytime*0.5;
		// 	var quarter= maxdelaytime*0.25;
		// 	DelayC.ar(snd, maxdelaytime, half+(quarter*LPF.ar(WhiteNoise.ar,SinOsc.kr(0.1,rrand(0,2*pi)).range(5,15))))/6
		// });
		//
		snd=snd*EnvGen.ar(Env.perc(0.005,10));
		Out.ar(0,snd*amp);
	}).add;
	s.sync;

	x = Synth("casioish",[\freq,60.midicps]);

	y = Synth("casioish",[\freq,62.midicps]);
	z = Synth("casioish",[\freq,65.midicps]);
	w = Synth("casioish",[\freq,60.midicps/2,\amp,1.0]);
}.play
)
	z = Synth("casioish",[\freq,64.midicps]);

