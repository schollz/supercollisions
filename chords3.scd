(
s.waitForBoot({
	SynthDef("jp2",{ | amp=0.75,note=40, mix=1.0, detune = 0.4,lpf=10,gate=1 |
		var freq=note.midicps;
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
		Out.ar(0,sig/2*EnvGen.ar(Env.perc(Rand(0.1,2),Rand(1,3),1,[4,-4]),timeScale:8,doneAction:2)*amp);
	}).send(s);
	SynthDef("sine",{
		arg note,gate=1;
		var snd=PulseDPW.ar([note-Rand(0,0.05),note+Rand(0,0.05)].midicps,SinOsc.kr(Rand(1,3),Rand(0,pi)).range(0.3,0.7));
		var env=EnvGen.ar(Env.perc(Rand(0.5,1.5),Rand(2,4),1,[4,-4]),timeScale:8,doneAction:2);
		snd=snd+PinkNoise.ar(SinOsc.kr(1/Rand(1,4),Rand(0,pi)).range(0.0,1.5));
		snd=snd*env/20;
		snd=RLPF.ar(snd,note.midicps*6,0.8);
		snd=snd*EnvGen.ar(Env.adsr(sustainLevel:1,releaseTime:Rand(5,10)),gate:gate,doneAction:2);
		snd=Balance2.ar(snd[0],snd[1],Rand(-1,1));
		Out.ar(0,snd);
	}).send(s);
	s.sync;
	SynthDef("out",{
		var snd2;
		var shimmer=1;
		var snd=In.ar(0,2);
		snd2=snd;
		snd2 = DelayN.ar(snd, 0.03, 0.03);
		snd2 = snd2 + PitchShift.ar(snd, 0.13, 2,0,1,1*shimmer/2);
		snd2 = snd2 + PitchShift.ar(snd, 0.1, 4,0,1,0.5*shimmer/2);
		snd2 = snd2 + PitchShift.ar(snd, 0.1, 8,0,1,0.125*shimmer/2);
		snd2=SelectX.ar(0.8,[snd2,Fverb.ar(snd2[0],snd2[1],100,decay:VarLag.kr(LFNoise0.kr(1/3),3).range(50,100))]);
		snd2=AnalogTape.ar(snd2,0.9,0.9,0.7);
		snd2=SelectX.ar(SinOsc.kr(1/11).range(0,0.3),[snd2,AnalogChew.ar(snd2,1.0,0.5,0.5)]);
		snd2=AnalogDegrade.ar(snd2,0.2,0.2,0.5,0.5);
		snd2=AnalogLoss.ar(snd2,0.5,0.5,0.5,0.5);
		snd2=snd2.tanh*0.7;
		snd2=HPF.ar(snd2,50);
		snd2=BPeakEQ.ar(snd2,24.midicps,1,3);
		//snd2=BPeakEQ.ar(snd2,660,1,-3);
		snd2=SelectX.ar(0.3,[snd2,Fverb.ar(snd2[0],snd2[1],100,decay:VarLag.kr(LFNoise0.kr(1/3),3).range(80,96))]);
		snd2=snd2*EnvGen.ar(Env.new([48.neg,0],[3])).dbamp/2;
		ReplaceOut.ar(0,snd2);
	}).send(s);
	s.sync;
	Synth.tail(s,"out");
	Routine {
		var seeds;
		var scale=[ 0, 2, 4, 5, 7, 9, 11 ];
		scale=scale++(scale+12);
		scale=scale++(scale+24);
		scale=scale++(scale+36);
		Routine {
			inf.do({ arg j;
				var spaces;
				var hm;
				var sleeptime=6*(1.5+(0.25*7.rand));
				var syns=List.new();
				if (j.mod(4)<1,{
					seeds=[100.rand,100.rand,100.rand,100.rand,100.rand].postln;
					//seeds=[[ 81, 29, 24, 23 ],[ 5, 94, 91, 73 ],[ 37, 60, 71, 92 ],[ 39, 96, 21, 71 ]].choose;
					seeds=[ 81, 29, 24, 23 ]; // THIS IS A NICE SEED!
					// seeds=[ 5, 94, 91, 73 ];
					// seeds=[ 37, 60, 71, 92 ];
					//seeds=[ 39, 96, 21, 71 ];
				});
				thisThread.randSeed = seeds[j.mod(seeds.size)];
				if (10.rand<10,{
					spaces={ 8.rand }!5;
					hm=[[4,3,2],[3,2,1],[2,2,3],[3,4,5]].choose.scramble;
					spaces[0]=8.rand;
					spaces[1]=hm[0];
					spaces[2]=hm[1];
					spaces[3]=hm[2];
					spaces.do({arg v,i;
						if (i>0,{
							spaces[i]=spaces[i]+spaces[i-1];
						},{
							syns.add(Synth.head(s,"jp2",[\note,scale[spaces[i]].mod(12)+24]));

						});
						syns.add(Synth.head(s,"sine",[\note,scale[spaces[i]]+48]));
						// [i,v,spaces[i]].postln;
					});
				});
				sleeptime.postln;
				(sleeptime).sleep;
				syns.do({arg v;
					v.postln;
					v.set(\gate,0);
				});
			});
		}.play;
	}.play;


});
)

[2,3].min