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
{
	var freqBase=100;
	var freqRes=120;
	var sr=SampleRate.ir;
	var baseFreqCounter=Phasor.ar(0,1,0,sr/freqBase);
	var resFreqCounter=Phasor.ar(baseFreqCounter<1,1,0,sr/freqRes);
	var sineWaveReadout=((2*pi*resFreqCounter/(sr/freqRes))+(1.5*pi)).sin+1;
	var invertedBaseFreq=((sr/freqBase)-baseFreqCounter)/(sr/freqBase);
	//[baseFreqCounter/(sr/freqBase),resFreqCounter/(sr/freqRes),sineWaveReadout,sineWaveReadout*invertedBaseFreq-(pi/4)]
	[resFreqCounter/(sr/freqRes),sineWaveReadout]
}.plot(1.3/100)
)

(
{
	var freqBase=100;
	var freqRes=MouseX.kr(100,1200);
	var sr=SampleRate.ir;
	var baseFreqCounter=Phasor.ar(0,1,0,sr/freqBase);
	var resFreqCounter=Phasor.ar(baseFreqCounter<1,1,0,sr/freqRes);
	var sineWaveReadout=((2*pi*resFreqCounter/(sr/freqRes))+(1.5*pi)).sin+1;
	var invertedBaseFreq=((sr/freqBase)-baseFreqCounter)/(sr/freqBase);
	var snd=sineWaveReadout*invertedBaseFreq-(pi/4);
	snd=LeakDC.ar(snd!2);
	snd=LPF.ar(snd,freqBase*4);
	Out.ar(0,snd);
}.play;
)

(
Routine {
	SynthDef("casioish",{
		arg freq=220, amp=0.5,gate=1;
		var y,z;
		var freqBase=freq;
		var freqRes=LFNoise2.kr(1).range(freq,freq*4);//MouseX.kr(freq,freq*4);
		var sr=SampleRate.ir;
		var baseFreqCounter=Phasor.ar(0,1,0,sr/freqBase);
		var resFreqCounter=Phasor.ar(baseFreqCounter<1,1,0,sr/freqRes);
		var sineWaveReadout=((2*pi*resFreqCounter/(sr/freqRes))+(1.5*pi)).sin+1;
		var invertedBaseFreq=((sr/freqBase)-baseFreqCounter)/(sr/freqBase);
		var snd=sineWaveReadout*invertedBaseFreq-(pi/4);
		snd=LeakDC.ar(snd);
		snd=LPF.ar(snd,freqBase*4);
		snd = snd * 0.1;
		snd=snd*EnvGen.ar(Env.adsr(0.2,1,0.9,1),gate,doneAction:2);

		Out.ar(0,Pan2.ar(snd,LFNoise2.kr(1)*0.1));
	}).add;
	s.sync;


	// w = Synth("casioish",[\freq,69.midicps,\amp,1.0]);
}.play
)
z = Synth("casioish",[\freq,64.midicps]);



(
// sequence
~crdStr = [["E1", "E2", "B3", "D4", "G4"],
	["G1", "G2", "B3", "D4", "F#4", "A4"],
	["B4"],
	["A1", "A2", "C4", "E4", "G4"],
	["C1", "C2", "G3", "E4", "G4"]
];

// Map from chord names to midi notes
~noteToMidi = {
	arg noteStr;
	var notes = Dictionary[
		"C"  -> 0,
		"C#" -> 1,
		"D"  -> 2,
		"D#" -> 3,
		"E"  -> 4,
		"F"  -> 5,
		"F#" -> 6,
		"G"  -> 7,
		"G#" -> 8,
		"A"  -> 9,
		"A#" -> 10,
		"B"  -> 11];
	var octave = noteStr.last.digit;
	var degree = notes[noteStr[..noteStr.size-2].postln];
	octave*12 + degree;
};

~crdArray = ~crdStr.collect{
	arg crd;
	crd.collect{|c| ~noteToMidi.(c)};
};

Pn(
	Plazy {
		Pbind(
			\instrument, \casioish,
			\freq, Pseq(~crdArray+12 , inf).midicps,
			\dur, 60/180*8*Pseq([1, 0.375, 0.625, 1, 1], 1),
			\sustain, 60/180*9*Pseq([1, 1, 0.625, 1, 1], 1)
		)
	},
	inf
).play;
)

