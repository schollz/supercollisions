(
SynthDef("pulsetrain",{ arg note=32;
	var freq=note.midicps;
	var snd;
	var width=LFNoise2.kr(1).range(0,0.5);
	var detune=LFNoise2.kr(1).range(0,0.05);
	var p2 = LFNoise2.kr(1).range(0,1);
	snd = Pulse.ar([note-detune,note+detune].midicps,width:width);
	snd = snd + DelayC.ar(Pulse.ar([note-detune,note+detune].midicps*2,width:width),1/freq,1/freq*LFNoise2.kr(1).range(0,1),p2);
	snd = LeakDC.ar(snd);
	snd = BLowPass.ar(snd,freq*LFNoise2.kr(1/3).range(12,16),0.707);
	snd = snd * EnvGen.ar(Env.new([0,1],Rand(3,9)));
	Out.ar(0,snd/6);
}).add;
)


(
SynthDef("p2",{ arg note=60;
	var freq=note.midicps;
	var g=MouseX.kr(0.25,0.75);
	var snd=LFPulse.ar(freq,width:0.)+
	DelayC.ar(LFPulse.ar(freq,width:1-g)*1.neg,1/freq,1/freq*g);
	//snd = BLowPass.ar(snd,freq*2*XLine.kr(10,1,0.5),0.707);
	snd = snd;
	Out.ar(0,snd/6);
}).play;
)
(
)

(
x=Synth.tail(s,"fx");
Synth.head(s,"pulsetrain",[\note,36,\amp,1]);
Synth.head(s,"pulsetrain",[\note,48,\amp,1]);
Synth.head(s,"pulsetrain",[\note,60]);
Synth.head(s,"pulsetrain",[\note,57]);
Synth.head(s,"pulsetrain",[\note,67]);
Synth.head(s,"pulsetrain",[\note,72]);
)

Synth.head(s,"pulsetrain",[\note,60]);

(
SynthDef("fx",{
	var snd=In.ar(0,2);
	snd=AnalogTape.ar(snd,0.8,0.9,0.8,2);
	snd=AnalogVintageDistortion.ar(snd*MouseX.kr(0.1,1),0.1,0.1);
	snd=SelectX.ar(LFNoise2.kr(1/3).range(0.15,0.5), [snd,Fverb.ar(snd[0],snd[1],60,decay:LFNoise2.kr(1/4).range(70,90))]);
	ReplaceOut.ar(0,snd);

}).add;

SynthDef("pulsetrain",{arg note=60,amp=1;
	var freq=note.midicps;
	var snd;
	var detune=LFNoise2.kr(1).range(0,0.05);
	var g=SinOsc.kr(1/Rand(1,3)).range(0.1,0.9).poll;
	var gy=LFNoise2.kr(1/Rand(1,3)).range(MouseY.kr(0,0.5),MouseY.kr(0,0.5)+0.5);
	note = note + SinOsc.kr(Rand(1,6),mul:0.02);
	g=SelectX.kr(gy,[g,SinOsc.kr(LinExp.kr(gy,0,1,1,freq/16)).range(0.4,0.8)]);
	snd=LFPulse.ar([note-detune,note+detune].midicps,width:Select.kr(g>0.5,[1-g,g]),mul:Saw.ar(freq,0.1,1))+
	DelayL.ar(LFPulse.ar([note-detune,note+detune].midicps,width:0.25)*1.neg,1/freq,1/freq*g,2)+
	DelayL.ar(LFPulse.ar([note-detune,note+detune].midicps,width:0.25)*1.neg,1/freq,1/freq*0.75)*0.1;
	snd = LPF.ar(snd,Clip.kr(freq*MouseX.kr(1,12)*(1+XLine.kr(3,0.01,Rand(1,8))),40,18000));
	// snd = BPeakEQ.ar(snd,freq*4,1,-6);
	snd = Balance2.ar(snd[0],snd[1],LFNoise2.kr(1/Rand(1,3),0.5));
	Out.ar(0,snd*amp*LinLin.kr(note,24,96,24,-6.0).dbamp/10);
}).add;
)

({Saw.ar(100,0.1,1)}.plot(0.1))
(
{
	var freq=80;
	var g=0.4;
	[LFPulse.ar(freq,width:Select.kr(g>0.5,[1-g,g]),mul:Saw.ar(freq,0.1,1))+
		DelayC.ar(LFPulse.ar(freq,width:0.25)*1.neg,1/freq,1/freq*g,2*1.4)+
		DelayC.ar(LFPulse.ar(freq,width:0.25)*1.neg,1/freq,1/freq*0.75,1.8)]}.plot(0.05);
)

(
{[LFPulse.ar(200,width:0.25)+DelayC.ar(LFPulse.ar(200,width:0.25)*1.neg,1/200,1/200*0.5)]}.play;
)