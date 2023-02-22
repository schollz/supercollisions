// Language -> Evaluate File
(
// s.record;
s.waitForBoot({
	Routine{
		// set the bpm
		var lastnote=false;
		var bpm=110;
		var scale=Scale.major;
		var octaves;
		var notes;
		var syncopation;
		var t = TempoClock(8*bpm/120);

		// define the synths
		SynthDef("jp",{ | amp=1,freq = 523.3572, mix=0.75, detune = 0.75,lpf=10 |
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

			var center = Mix.new(LFSaw.ar(freq, Rand()));
			var detuneFactor = freq * detuneCurve.(detune);
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
				LFSaw.ar(freqs[n], Rand(0, 2))
			});


			var sig = (center * centerGain.(mix)) + (side * sideGain.(mix));
			sig = HPF.ar(sig ! 2, freq);
			sig = MoogLadder.ar(sig,freq*lpf*3);
			sig = Pan2.ar(sig);
			Out.ar(0,sig/5*EnvGen.ar(Env.perc(0.0,1.5*amp),doneAction:2)*amp);
		}).send(s);
		SynthDef("final",{
			var snd2;
			var shimmer=1;
			var snd=In.ar(0,2);
			var sndR = Fverb.ar(snd[0],snd[1],200,decay:LFNoise2.kr(1/2).range(60,90));
			snd=SelectX.ar(LFNoise2.kr(1/3).range(0.0,0.001),[snd,sndR]);
			snd=AnalogTape.ar(snd,0.9,0.9,0.7,2);
			snd=BPeakEQ.ar(snd,32.midicps,6);
			ReplaceOut.ar(0,snd*0.25);
		}).send(s);

		SynthDef("sine",{
			arg note,gate=1,amp=0.5;
			var snd=Pulse.ar(([note-Rand(0,0.03),note+Rand(0,0.03)]+SinOsc.kr(Rand(0.1,1),0,Rand(0.001,0.002))).midicps,SinOsc.kr(Rand(1,3),Rand(0,pi)).range(0.25,0.7));
			var env=EnvGen.ar(Env.perc(Rand(0.1,0.5),Rand(2,4),1,[4,-4]),timeScale:2,doneAction:2);
			snd=snd*env/10;
			snd=RLPF.ar(snd,note.midicps*4,0.8);
			snd=snd*EnvGen.ar(Env.adsr(sustainLevel:1,releaseTime:Rand(5,10)),gate:gate,doneAction:2);
			snd=Balance2.ar(snd[0],snd[1],Rand(-0.2,0.2));
			Out.ar(0,snd*amp);
		}).send(s);
		s.sync;
		Synth.new("final",[],s,\addToTail);
		s.sync;

		notes=[0,2,4,0,2,4,0,2,0,2,4,0,2,4,0,2];
		notes=notes++[-1,2,4,-1,2,4,-2,2,-1,2,4,-1,2,4,-1,2];
		notes=notes++[-2,0,4,-2,0,4,-2,0,-2,0,4,-2,0,4,-2,0];
		notes=notes++[-2,0,3,-2,0,3,-2,2,-2,0,3,-2,0,3,-2,0];
		notes=notes++[5];
		//
		// notes=[0,3,7,5,0,3,7,5,0,3,7,5,0,3,7,5];
		// notes=[7,3,0,7,3,0,7,3,7,3,0,7,3,0,7,3];
		// notes=notes++[-1,2,5,-1,2,5,-1,2,-1,2,5,-1,2,5,-1,2];
		// notes=notes++[1,3,7,1,3,7,1,3,1,3,7,1,3,7,1,3];
		// notes=notes++[0,2,8,0,2,8,0,2,0,2,8,0,2,8,0,2];
		// notes=notes++[5];

		// define 65 notes
		notes=[-2,0,2,-2,0,2,-2,0,-2,0,2,-2,0,2,-2,0];
		notes=notes++[-2,0,3,-2,0,3,-2,0,-2,0,3,-2,0,3,-2,0];
		notes=notes++[-3,-1,2,-3,-1,2,-3,-1,-3,-1,2,-3,-1,2,-3,-1];
		notes=notes++[-3,-1,1,-3,-1,1,-3,-1,-3,-1,1,-3,-1,1,-3,-1];
		notes=notes++[3]; // 65th note is key
		scale=[0,2,4,5,7,9,11];
		octaves=[12,0,12,12,12,0,12,0];
		octaves=[0,0,0,12,12,12,24,24];
		syncopation=[1,0.5,1,0.5,0.5,1,0.5,1];
		syncopation=[1,1.5,0.2,0.5,0.5,1,0.5,1];
		syncopation=[1,1.1,0.9];
		lastnote=false;
		t.schedAbs(0, { arg i, sec;
			var note=scale[notes[i.mod(notes.size)].mod(scale.size)]+octaves[i.mod(octaves.size)]+36;
			var accent=syncopation[i.mod(syncopation.size)];
			[i,note-36,notes[i.mod(notes.size)],scale[notes[i.mod(notes.size)]]].postln;
			if (i.mod(16)<1,{
				"play chords".postln;
				4.do({arg j;
					var note2=scale[notes[(i+j).mod(notes.size)].mod(scale.size)]+octaves[(i+j).mod(octaves.size)]+36;
					Synth("sine",[\note,note2+12,\amp,1.4]);
				});
			});
			if ((100.rand<100)||(lastnote==false),{
				lastnote=true;
				Synth("jp",[\freq,note.midicps,\mix,(40+10.rand)/100,\detune,(25+30.rand)/100,\amp,accent,\lpf,18-(accent*12)]);
				},{
					lastnote=false;
			});
			1
		});

	}.play;
}
)
)

