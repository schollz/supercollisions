// Language -> Evaluate File
(
// s.record;
s.waitForBoot({
	Routine{
		// set the bpm
		var lastnote=false;
		var bpm=120;
		var scale=Scale.major;
		var octaves;
		var notes;
		var syncopation, in, local;
		t = TempoClock(8*bpm/120);

		// define the synths
		SynthDef("jp",{ | amp=1,freq = 120, mix=0.6, detune = 0.25,lpf=10 |
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
			var centerGain, sideGain, center, detuneFactor, freqs, side, sig, snd2;
			centerGain = { |x| (-0.55366 * x) + 0.99785 };
			sideGain = { |x| (-0.73764 * x.pow(2)) + (1.2841 * x) + 0.044372 };

			center = Mix.new(LFSaw.ar(freq, Rand()));
			freq = Vibrato.ar(K2A.ar(Lag.kr(freq,0.1)),Rand(5,7),0.01,0.05,0.5,0.08,0.2);
			detuneFactor = freq * detuneCurve.(detune);
			freqs = [
				(freq - (detuneFactor * 0.11002313)),
				(freq - (detuneFactor * 0.06288439)),
				(freq - (detuneFactor * 0.01952356)),
				// (freq + (detuneFactor * 0)),
				(freq + (detuneFactor * 0.01991221)),
				(freq + (detuneFactor * 0.06216538)),
				(freq + (detuneFactor * 0.10745242))
			];
			side = Mix.fill(6, { |n|
				LFSaw.ar(freqs[n], Rand(0, 2))
			});


			sig = (center * centerGain.(mix)) + (side * sideGain.(mix));
			sig = HPF.ar(sig ! 2, freq/2);
			sig = MoogLadder.ar(sig,freq*lpf*3);
			sig = Pan2.ar(sig);

			in = sig;
			local = LocalIn.ar(2);
			local = OnePole.ar(local, 0.4);
			local = OnePole.ar(local, -0.08);

			local = Rotate2.ar(local[0], local[1], 0.2);

			local = DelayC.ar(local, 0.25, LFNoise2.kr(1/5).range(0.249,0.25),0.3);
			local = local + DelayC.ar(local, 0.5, LFNoise2.kr(1/5).range(0.5,0.51),0.3);
			local = local + DelayC.ar(local, 0.75, LFNoise2.kr(1/5).range(0.75,0.76),0.3);

			local = LeakDC.ar(local);
			local = ((local + in) * LFNoise2.kr(1/3).range(0.5,0.7) * MouseY.kr(0.5,2.5)).softclip;

			LocalOut.ar(local);

			Out.ar(0,local*amp*LinLin.kr(freq.cpsmidi,20,90,2,0.5)/4);
		}).send(s);
		SynthDef("final",{
			var snd2;
			var shimmer=1;
			var snd=In.ar(0,2);
			var sndR = Fverb.ar(snd[0],snd[1],200,decay:LFNoise2.kr(1/2).range(60,90),tail_density:LFNoise2.kr(1/2).range(60,90));
			snd=AnalogTape.ar(snd,0.5,0.5,0.7,2);
			snd=SelectX.ar(LFNoise2.kr(1/3).range(0.5,0.6),[snd,sndR]);
			snd=BPeakEQ.ar(snd,32.midicps,6);
			ReplaceOut.ar(0,snd*0.05);
		}).send(s);
		s.sync;
		Synth.new("final",[],s,\addToTail);
		s.sync;
		x=Synth.new("jp",[\freq,60.midicps],s,\addToHead);
		Synth.new("jp",[\freq,(60+4).midicps],s,\addToHead);
		Synth.new("jp",[\freq,(60+9).midicps],s,\addToHead);
		Synth.new("jp",[\freq,(60-24).midicps,\lpf,8,\amp,2],s,\addToHead);
	}.play;
}
)
)
x=Synth.new("jp",[\freq,67.midicps],s,\addToHead);
x=Synth.new("jp",[\freq,77.midicps],s,\addToHead);
x.set(\freq,60.midicps)
x.set(\freq,59.midicps)
x.set(\freq,57.midicps)
x.set(\freq,62.midicps)
t = TempoClock(15*110/120);
