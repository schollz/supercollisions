(
s.waitForBoot({

	SynthDef("jp2",{
		arg outWet,outDry,db=0,freq=40,gate=1,wet=1,dur=1;
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
		var detuneFactor = freq * detuneCurve.(LFNoise2.kr(1/dur).range(0.3,0.5));
		var freqs = [
			(freq - (detuneFactor * 0.11002313)),
			(freq - (detuneFactor * 0.06288439)),
			(freq - (detuneFactor * 0.01952356)),
			(freq + (detuneFactor * 0.01991221)),
			(freq + (detuneFactor * 0.06216538)),
			(freq + (detuneFactor * 0.10745242))
		];
		var side = Mix.fill(6, { |n|
			SawDPW.ar(freqs[n], Rand(0, 2))
		});

		var mix = LFNoise2.kr(1/dur).range(0.7,1.0);
		var sig =  (center * centerGain.(mix)) + (side * sideGain.(mix));
		sig = HPF.ar(sig, freq);
		sig = BLowPass.ar(sig,freq*LFNoise2.kr(1/dur).range(4,20),1/0.707);
		sig = sig * EnvGen.ar(Env.adsr(Rand(5,10),1,1,Rand(5,10)),gate:gate,doneAction:2);
		sig = sig * 12.neg.dbamp * Lag.kr(db,dur).dbamp;
		sig = Pan2.ar(sig);
		Out.ar(outDry,sig*(1-wet));
		Out.ar(outWet,sig*wet);
	}).send(s);

	SynthDef("sine",{
		arg outWet,outDry,db=0,freq=40,gate=1,wet=1,dur=1;
		var note=Vibrato.kr(freq,LFNoise2.kr(1/dur).range(0.1,1),LFNoise2.kr(1/dur).range(0.001,0.005),0.01).cpsmidi;
		var snd=Pulse.ar([note-Rand(0,0.05),note+Rand(0,0.05)].midicps,SinOsc.kr(Rand(1,3),Rand(0,pi)).range(0.3,0.7));
		snd=snd+PinkNoise.ar(SinOsc.kr(1/LFNoise2.kr(1/dur).range(0.5,4),Rand(0,pi)).range(0.0,1.5));
		snd=RLPF.ar(snd,note.midicps*6,0.8);
		snd=snd*EnvGen.ar(Env.adsr(attackTime:dur,sustainLevel:1,releaseTime:dur*Rand(4,10)),gate:gate,doneAction:2);
		snd=Balance2.ar(snd[0],snd[1],Rand(-1,1));
		snd = snd * 24.neg.dbamp * Lag.kr(db,dur).dbamp;
		Out.ar(outDry,snd*(1-wet));
		Out.ar(outWet,snd*wet.poll);
	}).send(s);
	s.sync;
	SynthDef("out",{
		arg inWet, inDry;
		var snd2;
		var shimmer=0.25;
		var sndWet=In.ar(inWet,2);
		var sndDry=In.ar(inDry,2);
		sndWet = DelayN.ar(sndWet, 0.03, 0.03);
		sndWet = sndWet + PitchShift.ar(sndWet, 0.13, 2,0,1,1*shimmer/2);
		sndWet = sndWet + PitchShift.ar(sndWet, 0.1, 4,0,1,0.5*shimmer/2);
		sndWet=SelectX.ar(LFNoise2.kr(1/5).range(0.5,0.9),[sndWet,Fverb.ar(sndWet[0],sndWet[1],117,
			decay:VarLag.kr(LFNoise0.kr(1/3),3).range(50,100),
			tail_density:VarLag.kr(LFNoise0.kr(1/3),3).range(50,100),
		)]);
		snd2 = sndWet + sndDry;
		snd2=AnalogTape.ar(snd2,0.9,0.9,0.7);
		snd2=SelectX.ar(LFNoise2.kr(1/4).range(0,0.5),[snd2,AnalogChew.ar(snd2,1.0,0.5,0.5)]);
		snd2=SelectX.ar(LFNoise2.kr(1/4).range(0,0.5),[snd2,AnalogDegrade.ar(snd2,0.2,0.2,0.5,0.5)]);
		snd2=SelectX.ar(LFNoise2.kr(1/4).range(0,0.5),[snd2,AnalogLoss.ar(snd2,0.5,0.5,0.5,0.5)]);
		snd2=snd2.tanh*0.75;
		snd2=HPF.ar(snd2,20);
		snd2=BPeakEQ.ar(snd2,24.midicps,1,3);
		snd2=BPeakEQ.ar(snd2,660,1,-3);
		snd2=SelectX.ar(LFNoise2.kr(1/4).range(0.1,0.3),[snd2,Fverb.ar(snd2[0],snd2[1],100,decay:VarLag.kr(LFNoise0.kr(1/3),3).range(60,96))]);
		snd2=snd2*EnvGen.ar(Env.new([48.neg,0],[3])).dbamp;
		snd2 = Compander.ar(snd2,snd2)/2;
		snd2 = Limiter.ar(snd2,0.9);
		snd2 = snd2 * EnvGen.ar(Env.new([0,1],[3]));
		Out.ar(0,snd2);
	}).send(s);
	s.sync;


});
)

(
Routine{
	~busWet = Bus.audio(s,2);
	~busDry = Bus.audio(s,2);
	s.sync;
	~out = Synth.tail(s,"out",[
		inWet: ~busWet,
		inDry: ~busDry,
	]);
}.play;
)

rrand(3,10)
(
Routine{
	var dur=9.4;
	var syn=Synth.head(s,"jp2",[
		\db: -96,
		\outDry: ~busDry,
		\outWet: ~busWet,
		\dur: dur,
		\wet: 1.0,
	]);
	inf.do({ arg i;
		var notes=[69,60,69,64]-36;
		syn.set(\freq,notes[i%notes.size].midicps,\db,-2);
		dur.sleep;
	});
}.play;
)

(
Routine{
	var dur=7.3;
	var syn=Synth.head(s,"sine",[
		\db: -96,
		\outDry: ~busDry,
		\outWet: ~busWet,
		\dur: dur,
		\wet: 0.7,
	]);
	inf.do({ arg i;
		var notes=[67,69,72,67,69,65]-12;
		syn.set(\freq,notes[i%notes.size].midicps,\db,2);
		dur.sleep;
	});
}.play;
)

(
Routine{
	var dur=4.3;
	var syn=Synth.head(s,"sine",[
		\db: -96,
		\outDry: ~busDry,
		\outWet: ~busWet,
		\dur: dur,
		\wet: 0.7,
	]);
	inf.do({ arg i;
		var notes=[67,69,65,62]+12;
		syn.set(\freq,notes[i%notes.size].midicps,\db,2);
		dur.sleep;
	});
}.play;
)

(
Routine{
	var syn=Synth.head(s,"sine",[\db,-96]);
	inf.do({ arg i;
		var notes=[60,0,62,62,62,62,60];
		var note = notes[i%notes.size];
		if (note>0,{
			syn.set(\freq,note.midicps,\db,3);
		},{
			syn.set(\db,-96);
		});
		3.7.sleep;
	});
}.play;
)


(
Routine{
	var syn=Synth.head(s,"sine",[\db,-96]);
	inf.do({ arg i;
		var notes=[67,69,65,62]+12;
		var note = notes[i%notes.size];
		if (note>0,{
			syn.set(\freq,note.midicps,\db,3);
		},{
			syn.set(\db,-96);
		});
		3.7.sleep;
	});
}.play;
)

(
Routine{
	var syn=Synth.head(s,"sine",[\db,-96]);
	inf.do({ arg i;
		var notes=[67,69,65,62]+12;
		syn.set(\freq,notes[i%notes.size].midicps,\db,-1);
		5.7.sleep;
	});
}.play;
)

(
Routine{
	var syn=Synth.head(s,"sine",[\db,-96]);
	inf.do({ arg i;
		var notes=[64,65,67]+24;
		syn.set(\freq,notes[i%notes.size].midicps,\db,-3);
		7.1.sleep;
	});
}.play;
)

(
Routine{
	var syn=Synth.head(s,"sine",[\db,-96]);
	inf.do({ arg i;
		var notes=[60,64,69,64]-24;
		syn.set(\freq,notes[i%notes.size].midicps,\db,-3);
		0.2.sleep;
	});
}.play;
)


Scale.major.degrees+60