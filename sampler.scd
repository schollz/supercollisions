(
s.waitForBoot({
	Routine{
		SynthDef("sampler",{
			arg buf,out=0,t_trig,
			rate = 1.0,
			pos=0.0,
			dbVolume=0.0,
			xfade=0.005,
			bpmSource=120, bpmTarget=120,
			retrigNum=0,retrigRate=1;
			var snd,sndA,sndB,crossfade,aOrB;
			var posA,posB;
			var retrigTrig, retrigCount;
			var frames=BufFrames.ir(buf);
			var seconds=BufDur.ir(buf)*bpmSource/bpmTarget;

			// Calculate rate
			rate = rate*BufRateScale.ir(buf)*bpmTarget/bpmSource;

			// Calculate retrigger rate and count
			retrigTrig = SinOsc.ar(bpmTarget/60*retrigRate);
			retrigCount = Stepper.ar(retrigTrig,max:100000).poll;

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

			Out.ar(out,snd*Lag.kr(dbVolume.dbamp,2));
		}).send(s);

		s.sync;
		e=Buffer.read(s,"C:\\Users\\zacks\\Documents\\supercollisions\\amen_5c2d11c8_beats16_bpm170.flac");
		s.sync;

		["loaded"].postln;
	}.play;
});
)
(
x = Synth("sampler",[
	buf:e,
	bpmSource: 170,
	bpmTarge: 120,
	retrigNum: 16,
	retrigRate: 8,
	pos:0.0,
]);
)
x.set(\t_trig,1);
e.play;

