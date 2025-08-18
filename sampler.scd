(
s.waitForBoot({
	Routine{
		~serverLatency = 0.1;
		SynthDef("sampler",{
			arg buf,t_trig=1,
			gate = 1.0,
			rate = 1.0,
			pitch = 0.0,
			volumeDB=0.0,
			xfade=0.01,
			bpmSource=120, bpmTarget=120,
			// retriggering
			retrigNumTotal=0,
			retrigRateChangeBeats=1,
			retrigRateStart=1,
			retrigRateEnd=0,
			retrigPitchChange=0,
			retrigVolumeChange=0,
			sliceAttackBeats = 0.001,
			sliceDurationBeats = 0,
			sliceReleaseBeats = 0.001,
			sliceNum = 0,
			sliceCount = 32, // number of slices to cut the sample into
			effectDry = 1.0,
			effectDryOut,
			effectComb = 0.0,
			effectDelay = 0.0,
			effectReverb = 0.0,
			effectReverbOut
			;
			var snd,sndA,sndB,crossfade,aOrB;
			var sndDry, sndReverb, sndComb;
			var posA,posB;
			var retrigTrig, retrigCount;
			var frames=BufFrames.ir(buf);
			var seconds=BufDur.ir(buf)*bpmSource/bpmTarget;
			var pos = 0.0;
			var sliceTrigger = t_trig;
			var beatDuration = 60 / bpmTarget;
			var retrigCountFeedback = 0;
			
			sliceNum = sliceNum.mod(sliceCount);
			// convert slice beat to seconds
			pos = sliceNum / sliceCount;
			
			// make sure retrigRateEnd is at least retrigRateStart
			retrigRateEnd = Select.kr(retrigRateEnd < retrigRateStart, [retrigRateEnd, retrigRateStart]);
			
			// if sliceDurationBeats = 0, make it infinite
			sliceDurationBeats = Select.kr(sliceDurationBeats < 0.001, [sliceDurationBeats, 1e3]);
			
			// Calculate rate
			rate = rate*BufRateScale.ir(buf)*bpmTarget/bpmSource;
			// Calculate pitch
			rate = rate * (2 ** (pitch/12.0));
			
			// Calculate retriggers
			retrigCountFeedback = LocalIn.ar(1);
			retrigTrig = Impulse.ar(XLine.ar(retrigRateStart,retrigRateEnd,beatDuration*retrigRateChangeBeats) / beatDuration);
			retrigCount = PulseCount.ar(retrigTrig * (retrigCountFeedback<retrigNumTotal));
			sliceTrigger = sliceTrigger + (retrigTrig*(retrigCount<retrigNumTotal));
			
			// Increase pitch based on retrigger
			// rate = rate * (2 ** (retrigCount / 12));
			// Lower pitch based on retrigger
			rate = rate * (2 ** (retrigPitchChange * (retrigCount / 12)));
			
			// Change volume based on retrigger
			volumeDB = volumeDB + (A2K.kr(retrigCount) * retrigVolumeChange);
			
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
			
			snd = snd * Lag.kr(volumeDB.dbamp,0.2);
			
			// full envelope
			snd = snd * EnvGen.ar(Env.adsr(xfade,0.0,1.0,xfade,curve:\sine),gate,doneAction:2);
			
			// slice envelope
			snd = snd * EnvGen.ar(Env.new([0,1,1,0],[sliceAttackBeats,sliceDurationBeats,sliceReleaseBeats]*beatDuration,[-4,4]), sliceTrigger);
			
			// effects, comb filter
			snd = SelectX.ar(effectComb,[snd, (0.5*snd)+
				Pan2.ar(CombN.ar(snd[0], 0.02, Rand(0.01,0.06), Rand(1,2)),-1,0.9) +
				Pan2.ar(CombN.ar(snd[1], 0.02, Rand(0.01,0.06), Rand(1,2)),1,0.9)
			]);

			DetectSilence.ar(snd,time:1,doneAction:2);

			// Feedback
			LocalOut.ar(retrigCount);

			Out.ar(effectDryOut, snd*effectDry);
			Out.ar(effectReverbOut, snd*effectReverb);
		}).add;
		SynthDef("out",{
			arg busReverb, busDry,volumeDB=0.0,reverbAmt=0.1;
			var sndWet = In.ar(busReverb,2) * Lag.kr(volumeDB.dbamp,2);
			var sndDry = In.ar(busDry,2) * Lag.kr(volumeDB.dbamp,2);
			var snd = sndDry;

			// add in reverb
			snd = SelectX.ar(
				reverbAmt,[
					sndDry,
					Fverb.ar(sndWet[0],sndWet[1],200,tail_density: LFNoise2.ar(1/3).range(50,90),decay: LFNoise2.ar(1/3).range(50,70))
				]
			);
			
			snd = RHPF.ar(snd,60,0.303);
			snd = AnalogTape.ar(snd,0.8,0.8,0.8,2);
			ReplaceOut.ar(0,snd*0.2);
		}).add;
		
		s.sync;
		~busDry = Bus.audio(s, 2);
		~busReverb = Bus.audio(s, 2);
		s.sync;
		~synOut = Synth.tail(s,"out",[
			busReverb: ~busReverb,
			busDry: ~busDry,
			volumeDB: 6,
		]);
		s.sync;
		~sampleCache = Dictionary.new();

		~filename = "C:\\Users\\zacks\\Documents\\supercollisions\\amen_5c2d11c8_beats16_bpm170.flac";
		~filename = "/home/zns/Documents/supercollisions/amen_5c2d11c8_beats16_bpm170.flac";
		e=Buffer.read(s,~filename,action:{
			arg b;
			["loaded",b].postln;

			s.makeBundle(~serverLatency,{
				x = Synth.head(s,"sampler",[
					buf:b,
					effectDryOut: ~busDry,
					effectReverbOut: ~busReverb,
					bpmSource: 170,
					bpmTarget: 185,
					retrigRateStart: 0.5,
					retrigRateEnd: 16,
					retrigRateChangeBeats: 16,
					retrigNumTotal: 64,
					// retrigPitchChange: 12,
					// pitch:12,
					sliceDurationBeats: 1.0,
					retrigVolumeChange: 0.0,
					volumeDB: 0,
					sliceNum: 0,
					sliceCount:32,
				]).onFree({
					[b,"freed"].postln;
				});
			});
			// Pbind(
			// 	\instrument, \sampler,  // Add this line
			// 	\addAction, 0,  
			// 	\buf, b,
			// 	\effectDryOut, ~busDry,
			// 	\effectReverbOut, ~busReverb,
			// 	\bpmSource, 170,
			// 	\bpmTarget, 185,
			// 	\retrigRateStart, Prand([0,0,0,16,0,8],inf),
			// 	\retrigRateEnd, Prand([0,0,0,0,0,32,0],inf),
			// 	\retrigRateChangeBeats, 1,
			// 	\retrigNumTotal, Prand([0,0,0,16,0,8],inf),
			// 	\retrigPitchChange, Prand([0,1,4,8,15],inf),
			// 	\pitch, 0,
			// 	\sliceDurationBeats, 0.9,
			// 	\retrigVolumeChange, 0.0,
			// 	\volumeDB, 0,
			// 	\sliceNum, Pseq((0..15), inf),
			// 	\sliceCount, 16,
			// 	\xfade, 0.01,
			// 	\dur, 60/185,
			// 	\legato, 1.0,
			// ).play;

		});
		
		// x.set(\t_trig,1);
		// e.play;
		~playFromMsg = {
			arg msg;
			["playing",msg[3]].postln;

		};


		o.free;
		o = OSCFunc({ |msg|
			var filename = msg[3];
			if (~sampleCache.at(filename).isNil,{
				~playFromMsg.(msg);
			},{
				// load sample
				~sampleCache.put(filename, Buffer.read(s,filename,action:{ |b|
					["loaded",b].postln;
					~playFromMsg.(msg);
				}));
			});
		}, '/sampler');
		["loaded"].postln;
	}.play;
});
)

