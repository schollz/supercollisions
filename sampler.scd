(
s.waitForBoot({
	Routine{
		SynthDef("sampler",{
			arg buf,outDry=0,outWet=0,t_trig=1,dryWet=0.0,
			gate = 1.0,
			rate = 1.0,
			dbVolume=0.0,
			xfade=0.005,
			bpmSource=120, bpmTarget=120,
			attack=0.01,
			release=0.01,
			// retriggering
			retrigNumTotal=0,
			retrigRateChangeBeats=1,
			retrigRateStart=1,
			retrigRateEnd=0,
			sliceAttackBeats = 0.01,
			sliceDurationBeats = 1,
			sliceReleaseBeats = 0.01,
			sliceNum = 0,
			sliceCount = 32; // number of slices to cut the sample into
			var snd,sndA,sndB,crossfade,aOrB;
			var sndWet, sndDry;
			var posA,posB;
			var retrigTrig, retrigCount;
			var frames=BufFrames.ir(buf);
			var seconds=BufDur.ir(buf)*bpmSource/bpmTarget;
			var pos = 0.0;
			var sliceTrigger = t_trig;
			var beatDuration = 60 / bpmTarget;

			sliceNum = sliceNum.mod(sliceCount);
			// convert slice beat to seconds
			pos = sliceNum / sliceCount;

			// make sure retrigRateEnd is at least retrigRateStart
			retrigRateEnd = Select.kr(retrigRateEnd < retrigRateStart, [retrigRateEnd, retrigRateStart]);

			// if sliceDurationBeats = 0, make it infinite
			sliceDurationBeats = Select.kr(sliceDurationBeats < 0.001, [sliceDurationBeats, 1e3]);

			// Calculate rate
			rate = rate*BufRateScale.ir(buf)*bpmTarget/bpmSource;

			// Calculate retriggers
			retrigTrig = Impulse.ar(XLine.ar(retrigRateStart,retrigRateEnd,beatDuration*retrigRateChangeBeats) / beatDuration);
			retrigCount = PulseCount.ar(retrigTrig);
			[retrigCount,retrigNumTotal].poll;
			sliceTrigger = sliceTrigger + (retrigTrig*(retrigCount<retrigNumTotal));

			// Increase pitch based on retrigger
			// rate = rate * (2 ** (retrigCount / 12));
			// Lower pitch based on retrigger
			rate = rate * (2 ** (-1 * (retrigCount / 12)));

			// Determine whether to toggle playback
			aOrB=ToggleFF.ar(sliceTrigger);
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

			// full envelope
			snd = snd * EnvGen.ar(Env.adsr(attack,0.0,1.0,release),gate,doneAction:2);

			// slice envelope
			snd = snd * EnvGen.ar(Env.new([0,1,1,0],[sliceAttackBeats,sliceDurationBeats,sliceReleaseBeats]*beatDuration,[-4,4]), sliceTrigger);

			dryWet = Lag.kr(dryWet, 2);


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
					Fverb.ar(sndWet[0],sndWet[1],200,tail_density: LFNoise2.ar(1/3).range(50,90),decay: LFNoise2.ar(1/3).range(50,70))
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
				retrigRateStart: 1,
				retrigRateEnd: 32,
				retrigRateChangeBeats: 64,
				retrigNumTotal: 32,
				sliceDurationBeats: 0.5,
				sliceNum: 23,
				sliceCount:32,
			]);

		});

		// x.set(\t_trig,1);
		// e.play;

		["loaded"].postln;
	}.play;
});
)

