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



(
{[LFPulse.ar(200,width:0.25)+DelayC.ar(LFPulse.ar(200,width:0.25)*1.neg,1/200,1/200*0.5)]}.play;
)






({
	arg freq=20;
	[LFGauss.ar(1/freq,1/freq*4,0.5),LFGauss.ar(1/freq,1/freq*4,0)]
}.plot(0.2);
)


(
{
	arg freq=100;
	[LFGauss.ar(1/freq,0.125,0.5),LFGauss.ar(1/freq,0.125,0.25.neg),LFGauss.ar(1/freq,0.125,0.5)+LFGauss.ar(1/freq,0.125,0.5.neg)]
}.plot(1/100*4);
)





// attempt 1
(
{
	var freq=100;
	var x={
		arg g;
		LFPulse.ar(freq,width:Select.kr(g>0.5,[1-g,g]),mul:Saw.ar(freq,0.2,1))+
		DelayC.ar(LFPulse.ar(freq,width:0.25)*1.neg,1/freq,1/freq*g,2*1.4)+
		DelayC.ar(LFPulse.ar(freq,width:0.25)*1.neg,1/freq,1/freq*0.75,1.8)
	};
	[x.value(0.75),x.value(0.4),x.value(0.25)]}.plot(4/100);
)

// attempt 2
(
{
	arg freq=100;
	x={arg y;
		var width=0.2;
		1.neg*LeakDC.ar(LFGauss.ar(1/freq,width,0.5)+LFGauss.ar(1/freq,width,y),0.995)};
	[x.value(0.5),x.value(0.0),x.value(-0.5)]
}.plot(1/100*4);
)
// First Order Filter
(
{
	arg freq=100;
	x={arg y;
		var width=0.2;
		1.neg*FOS.ar(LFGauss.ar(1/freq,width,0.5)+LFGauss.ar(1/freq,width,y),1,-1,0.995)};
	[x.value(0.5),x.value(0.0),x.value(-0.5)]
}.plot(1/100*4);
)





(
x=Synth.tail(s,"fx");
Synth.head(s,"pulsetrain",[\note,60]);
Synth.head(s,"pulsetrain",[\note,57]);
Synth.head(s,"pulsetrain",[\note,67]);
)

Synth.head(s,"pulsetrain",[\note,36]);

(
SynthDef("fx",{
	var snd=In.ar(0,2);
	snd=SelectX.ar(LFNoise2.kr(1/3).range(0.15,0.5), [snd,Fverb.ar(snd[0],snd[1],60,decay:LFNoise2.kr(1/4).range(70,90))]);
	ReplaceOut.ar(0,snd);

}).add;
SynthDef("pulsetrain",{
	arg note=60;
	var freq=note.midicps;
	var snd;
	var x={arg y;
		var width=LinLin.kr(y,0.5,0.5.neg,0.09,0.13); // 0.11 is best, but 0.13 helps make a nice sine-like wave at the end
		var height=LinLin.kr(y,0.5.neg,0.5,1,0.5);
		(height*LFGauss.ar(1/freq,width,0.5))+(MouseY.kr()*LFGauss.ar(1/freq,width,y))
	};
	snd=x.value(MouseX.kr(-0.5,0.5));
	snd=LPF.ar(snd,freq*3);
	snd=Pan2.ar(snd,0);
	Out.ar(0,snd/10);
}).add;
)




// square pulses
(
{
	arg freq=100;
	var	x={arg y;
				var width=0.125; // trial and error
				var amp=LinLin.kr(y,0,0.5,1,1); // volume compensation
				var height=LinLin.kr(y,0,0.5,1.6,1); // height compensation
				var base_height=0.5; // trial and error
				var base_offset=0.0; // trial and error
				//var snd_=(DelayL.ar(LFPulse.ar(freq,0,width,base_height),1/freq,1/freq*y))+(LFPulse.ar(freq,base_offset,width,height*base_height));
				var snd_=(base_height*LFGauss.ar(1/freq,width,0.5))+(base_height*height*LFGauss.ar(1/freq,width,(y*2-0.5)*1.neg));
				snd_=LeakDC.ar(snd_,0.995)+DelayN.ar(Saw.ar(freq,0.05),1/freq,0.90/freq,1.neg);
				snd_=LPF.ar(amp*snd_,Clip.kr(freq*3.5*XLine.kr(4,1,0.6),20,20000))*1.neg
			};
	[x.value(0.0.neg),x.value(0.5),DelayN.ar(Saw.ar(freq),1/freq,0.925/freq)]
}.plot(1/100*5);
)

s.stopRecording
(
s.waitForBoot({
	Routine{

		SynthDef("fx",{
			var snd=In.ar(0,2);
			snd=SelectX.ar(LFNoise2.kr(1/3).range(0.15,0.5), [snd,Fverb.ar(snd[0],snd[1],60,decay:LFNoise2.kr(1/4).range(70,90))]);
			ReplaceOut.ar(0,snd);

		}).add;
		SynthDef("pulsetrain",{
			arg note=72,modh=0;
			var freq=(note+LFTri.kr(3).range(-0.05,0.05)).midicps;
			var snd;
			var	x={arg y,mod=0;
				var width=0.15; // trial and error
				var amp=LinLin.ar(y,0,0.5,0.5,1); // volume compensation
				var saw=LinLin.ar(y,0.0,0.5,0.25,0.0);
				var crossover=0.25;
				var height1=Select.ar(y>crossover,[
					LinLin.ar(y,0,crossover,0.5,1.1),
					LinLin.ar(y,crossover,0.5,1.1,1)
				])*mod;
				var height2=1;
				//var height1=LinLin.kr(y,0,0.5,1.5,1);
				var base_height=LinLin.ar(y,0.0,0.5,0.5,0.5); // trial and error
				var onepole=LinExp.ar(y,0,0.5,0.96,0.995);
				var base_offset=0.0; // trial and error
				//var snd_=(DelayL.ar(LFPulse.ar(freq,0,width,base_height),1/freq,1/freq*y))+(LFPulse.ar(freq,base_offset,width,height1*base_height));
				var snd_=(base_height*height2*LFGauss.ar(1/freq,width,0.5+base_offset))+(base_height*height1*LFGauss.ar(1/freq,width,(y*2-0.5)*1.neg));
				//snd_=LeakDC.ar(snd_,onepole);//+DelayN.ar(Saw.ar(freq,saw),1/freq,0.91/freq,1.neg);
				// higher HPF cutoff creates more
				// sloping in the initial segment of the curve
				snd_=BHiPass.ar(snd_,freq/8,0.707);
				snd_=LeakDC.ar(snd_,0.99); // more DC offset fix
				snd_=snd_*1.neg
				//snd_=LPF.ar(amp*snd_,Clip.kr(freq*1*XLine.kr(4,1,0.6),20,20000))
			};
			//snd=x.value(SinOsc.kr(freq/8).range(0,0.5),freq/13)/2;
			// snd=x.value(Line.kr(0.0,0.5,3,doneAction:2),0)/2;
			snd=x.value(LFNoise2.ar(freq/4).range(0.1,0.4),LFNoise2.ar(freq/32).range(0.5,1));
			snd=(snd*Line.kr(1,1.4,0.6))+Saw.ar(freq,mul:Line.kr(0.21,0.0,0.15));
			snd=snd.tanh/4;
			Out.ar(0,snd!2);
		}).add;
		s.sync;
		s.record;
		Synth("pulsetrain");
		3.wait;
		s.stopRecording;
	}.play;
})
)


(
x=Synth.tail(s,"fx");
)

(
Synth.head(s,"pulsetrain",[\note,72,\modh,16]);
Synth.head(s,"pulsetrain",[\note,57+12,\modh,8]);
Synth.head(s,"pulsetrain",[\note,67+12,\modh,4]);
)

(
SynthDef("pulsetrain",{
	arg note=60;
	var freq=note.midicps;
	var snd;
	var x={arg y;
		var width=0.15;
		var height=LinLin.kr(y,0,0.5,2,1);
		var snd_=DelayL.ar(LFPulse.ar(freq,0,width),1/freq,1/freq*y)+LFPulse.ar(freq,0,width,height);
		snd_=LeakDC.ar(snd_,0.999)*1.neg
	};
	snd=x.value(MouseX.kr(0,0.5));
	snd=LPF.ar(snd,freq*2);
	snd=Pan2.ar(snd,0);
	Out.ar(0,snd/2);
}).add;
)


