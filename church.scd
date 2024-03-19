(
s.waitForBoot({

	SynthDef("jp2",{ | out,amp=0.75,db=0,freq=40, mix=1.0, detune = 0.4,lpf=10,gate=1,timeScale=8 |
		var note=freq.cpsmidi;
		var detuneCurve = { |x|
			(10028.7312891634*x.pow(11)) -
			(50818.8652045924*x.pow(10)) +
			(111363.4808729368*x.pow(9)) -
			(138150.6761080548*x.pow(8)) +
			(106649.6679158292*x.pow(7)) -
			(53046.9642751875*x.pow(6)) +
			(17019.9518580080*x.pow(5)) -
			(3425.0836591318*x.pow(4)) +
			(404.2703938388*x.pow(3)) -
			(24.1878824391*x.pow(2)) +
			(0.6717417634*x) +
			0.0030115596
		};
		var centerGain = { |x| (-0.55366 * x) + 0.99785 };
		var sideGain = { |x| (-0.73764 * x.pow(2)) + (1.2841 * x) + 0.044372 };

		var center = Mix.new(SawDPW.ar(freq, Rand()));
		var detuneFactor = freq * detuneCurve.(LFNoise2.kr(1).range(0.3,0.5));
		var freqs = [
			(freq - (detuneFactor * 0.11002313)),
			(freq - (detuneFactor * 0.06288439)),
			(freq - (detuneFactor * 0.01952356)),
			// (freq + (detuneFactor * 0)),
			(freq + (detuneFactor * 0.01991221)),
			(freq + (detuneFactor * 0.06216538)),
			(freq + (detuneFactor * 0.10745242))
		];
		var side = Mix.fill(6, { |n|
			SawDPW.ar(freqs[n], Rand(0, 2))
		});


		var sig =  (center * centerGain.(mix)) + (side * sideGain.(mix));
		sig = HPF.ar(sig ! 2, freq);
		sig = BLowPass.ar(sig,freq*LFNoise2.kr(1).range(4,20),1/0.707);
		sig = Pan2.ar(sig);
		sig=sig*EnvGen.ar(Env.adsr(sustainLevel:1,releaseTime:Rand(5,10)),gate:gate,doneAction:2);
		Out.ar(0,sig*amp*12.neg.dbamp*db.dbamp);
	}).send(s);
	SynthDef("sine",{
		arg out,freq,gate=1,timeScale=8,dur=1,db=0;
		var note=Vibrato.kr(freq,Rand(0.1,0.4),0.005/Rand(1,4),0.01).cpsmidi;
		var snd=Pulse.ar([note-Rand(0,0.05),note+Rand(0,0.05)].midicps,SinOsc.kr(Rand(1,3),Rand(0,pi)).range(0.3,0.7));
		snd=snd+PinkNoise.ar(SinOsc.kr(1/Rand(1,4),Rand(0,pi)).range(0.0,1.5));
		snd=RLPF.ar(snd,note.midicps*6,0.8);
		snd=snd*EnvGen.ar(Env.adsr(attackTime:Rand(dur/2,dur*2),sustainLevel:1,releaseTime:Rand(4,10)),gate:gate,doneAction:2);
		snd=Balance2.ar(snd[0],snd[1],Rand(-1,1));
		Out.ar(0,snd*24.neg.dbamp*db.dbamp);
	}).send(s);
	s.sync;
	SynthDef("out",{ arg gate=1, in;
		var snd2;
		var shimmer=0.25;
		var snd=In.ar(0,2);
		snd2=snd;
		snd2 = DelayN.ar(snd, 0.03, 0.03);
		snd2 = snd2 + PitchShift.ar(snd, 0.13, 2,0,1,1*shimmer/2);
		snd2 = snd2 + PitchShift.ar(snd, 0.1, 4,0,1,0.5*shimmer/2);
		// snd2 = snd2 + PitchShift.ar(snd, 0.1, 8,0,1,0.125*shimmer/2);
		snd2=SelectX.ar(0.8,[snd2,Fverb.ar(snd2[0],snd2[1],100,decay:VarLag.kr(LFNoise0.kr(1/3),3).range(50,100))]);
		snd2=snd2*0.5;
		snd2=AnalogTape.ar(snd2,0.9,0.9,0.7);
		// snd2=SelectX.ar(LFNoise2.kr(1/4).range(0,0.5),[snd2,AnalogChew.ar(snd2,1.0,0.5,0.5)]);
		// snd2=SelectX.ar(LFNoise2.kr(1/4).range(0,0.5),[snd2,AnalogDegrade.ar(snd2,0.2,0.2,0.5,0.5)]);
		// snd2=SelectX.ar(LFNoise2.kr(1/4).range(0,0.5),[snd2,AnalogLoss.ar(snd2,0.5,0.5,0.5,0.5)]);
		snd2=snd2.tanh*0.75;
		snd2=HPF.ar(snd2,50);
		snd2=BPeakEQ.ar(snd2,24.midicps,1,3);
		snd2=BPeakEQ.ar(snd2,660,1,-3);
		snd2=SelectX.ar(LFNoise2.kr(1/4).range(0.6,0.8),[snd2,Fverb.ar(snd2[0],snd2[1],100,decay:VarLag.kr(LFNoise0.kr(1/3),3).range(60,96))]);
		snd2=snd2*EnvGen.ar(Env.new([48.neg,0],[3])).dbamp;
		snd2 = Compander.ar(snd2,snd2)/4;
		snd2 = Limiter.ar(snd2,0.9);
		ReplaceOut.ar(0,snd2*EnvGen.ar(Env.adsr(sustainLevel:1,releaseTime:3),gate:gate,doneAction:2));
	}).send(s);
	s.sync;


});
)

(
Routine{
	~out = Synth.tail(s,"out");

}.play;
)

(


(
Pbind(\instrument, \jp2,
	\freq, (Pseq([69,60,69,64], inf)-36).midicps,
	\dur, 9.4,
	\db, -2,
).play;
)


(
Pbind(\instrument, \sine,
	\freq, (Pseq([67,69,72,67,69,65], inf)-12).midicps,
	\dur, 4,
	\db, 5,
).play;
)


(
Pbind(\instrument, \sine,
	\freq, Pseq([60,60,62,62,62,62,60], inf).midicps,
	\dur, 3.7,
	\db, 3,
).play;
)


(
Pbind(\instrument, \sine,
	\freq, (Pseq([67,69,65,62], inf)+12).midicps,
	\dur, 5,
	\db, -1,
).play;
)

(
Pbind(\instrument, \sine,
	\freq, (Pseq([64,65,67], inf)+24).midicps,
	\dur, 11,
	\db, -4,
).play;
)

