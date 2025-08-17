(
s.waitForBoot({
	Routine{
		SynthDef("sampler",{
			arg buf,outDry=0,outWet=0,t_trig,dryWet=0.0,
			gate = 1.0,
			rate = 1.0,
			pos=0.0,
			dbVolume=0.0,
			xfade=0.005,
			bpmSource=120, bpmTarget=120,
			attack=0.01,
			release=0.01,
			retrigNum=0,retrigRate=1,retrigIncrease=0;
			var snd,sndA,sndB,crossfade,aOrB;
			var sndWet, sndDry;
			var posA,posB;
			var retrigTrig, retrigCount, retrigCountFeedback, retrigMultiplier = 1;
			var frames=BufFrames.ir(buf);
			var seconds=BufDur.ir(buf)*bpmSource/bpmTarget;
			var mainPhase=Phasor.ar(1,1/s.sampleRate,0,1000000);
			var eigthBeat=(mainPhase*bpmTarget/60).floor.poll;

			// Calculate rate
			rate = rate*BufRateScale.ir(buf)*bpmTarget/bpmSource;


			// Feedback pieces
			retrigCountFeedback = LocalIn.ar(1);

			// Calculate retrigger rate and count
			retrigMultiplier = Select.kr(
				retrigIncrease > 0, 
				[1, retrigIncrease / 10 * (retrigCountFeedback.sqrt + 1)]  
			);
			retrigTrig = SinOsc.ar(bpmTarget/60*retrigRate*retrigMultiplier);
			retrigCount = PulseCount.ar(retrigTrig).poll;

			// Determine whether to toggle playback
			aOrB=ToggleFF.kr(t_trig+(retrigTrig*(retrigCount<retrigNum)));
			crossfade=VarLag.ar(K2A.ar(aOrB),xfade,warp:\sine);

			posA=Phasor.ar(
				trig:(1-aOrB),
				rate:rate.abs,
				end:frames,
				resetPos:pos*frames,
			);
			posB=Phasor.ar(
				trig:aOrB,
				rate:rate.abs,
				end:frames,
				resetPos:pos*frames,
			);
			snd=(BufRd.ar(
				numChannels:2,
				bufnum:buf,
				phase:posA,
			)*crossfade)+(BufRd.ar(
				numChannels:2,
				bufnum:buf,
				phase:posB,
			)*(1-crossfade));

			snd = snd * Lag.kr(dbVolume.dbamp,2);
			snd = snd * EnvGen.ar(Env.adsr(attack,0.0,1.0,release),gate,doneAction:2);
			dryWet = Lag.kr(dryWet,2);

			// Feedback pieces
			LocalOut.ar(retrigCount);

			Out.ar(outDry,snd*(1-dryWet));
			Out.ar(outWet,snd*dryWet);
		}).send(s);
		SynthDef("out",{
			arg busWet, busDry,dbVolume=0.0,reverbAmt=0.1;
			var sndWet = In.ar(busWet,2) * Lag.kr(dbVolume.dbamp,2);
			var sndDry = In.ar(busDry,2) * Lag.kr(dbVolume.dbamp,2);
			var snd;

			// add in reverb
			snd = SelectX.ar(
				reverbAmt,[
					sndDry,
					Fverb.ar(sndWet[0],sndWet[1],200,tail_density: LFNoise2.kr(1/3).range(50,90),decay: LFNoise2.kr(1/3).range(50,70))
				]
			);

			snd = RHPF.ar(snd,60,0.303);

			snd = AnalogTape.ar(snd,0.8,0.8,0.8,2);

			ReplaceOut.ar(0,snd);
		}).send(s);

		s.sync;
		~busDry = Bus.audio(s, 2);
		~busWet = Bus.audio(s, 2);
		s.sync;
		~synOut = Synth.tail(s,"out",[
			busWet: ~busWet,
			busDry: ~busDry,
			dbVolume: 6,
		]);
		s.sync;

		~filename = "C:\\Users\\zacks\\Documents\\supercollisions\\amen_5c2d11c8_beats16_bpm170.flac";
		~filename = "/home/zns/Documents/supercollisions/amen_5c2d11c8_beats16_bpm170.flac";
		e=Buffer.read(s,~filename,action:{
			arg b;
			["loaded",b].postln;
			x = Synth.head(s,"sampler",[
				buf:b,
				outDry: ~busDry,
				outWet: ~busWet,
				bpmSource: 170,
				bpmTarget: 185,
				retrigNum: 32,
				retrigRate: 0.5,
				pos:0.0,
			]);

		});

		// x.set(\t_trig,1);
		// e.play;

		["loaded"].postln;
	}.play;
});
)

