(
SynthDef("metronome",{
	arg out,bpm_target;
	var mainPhase=Phasor.ar(1,1/s.sampleRate,0,1000000);
	var eigthBeat=(bpm_target/60*A2K.kr(mainPhase)*2).floor;
	SendReply.kr(trig: Changed.kr(eigthBeat), cmdName: '/beat',values: [eigthBeat]);
	Out.ar(out,mainPhase);
}).add;
SynthDef("op",{
	arg out=0,amp=1.0,busin,bufnum,bpm_source=120,bpm_target=140,t_trig=0,rate=1,xfade=0.01,slice_factor=1,compression=0.3,init_steps=4,be_normal=1,reverb=0,pan=0,doDecimate=0;
	var sig,snd,snd2,crossfade,aOrB,resetPos,retriggerNum,retriggerTrig,retriggerRate,doGate;
	var posA,posB;
	var beatsInPhrase=32;
	var mainPhase=In.ar(busin);
	var slices=(BufDur.ir(bufnum)/(60/bpm_source)).round*slice_factor;
	var slicesPlus=slices+0.999;
	var start=Impulse.kr(0);
	var numBeat=(bpm_target/60*A2K.kr(mainPhase)).floor;
	var changeBeat1=start+Changed.kr(numBeat);
	var changeBeatEighth=start+Changed.kr((bpm_target/60*A2K.kr(mainPhase)*2).floor);
	var changeBeat2=start+Changed.kr(numBeat%2<1);
	var changeBeat4=start+Changed.kr(numBeat%4<1);
	var changeBeat16=start+Changed.kr(numBeat%16<1);
	var changeBeatEnd=Trig.kr(numBeat%beatsInPhrase>(beatsInPhrase-2));
	var changeBeatStart=Trig.kr((numBeat%beatsInPhrase)<1);
	var frames=BufFrames.ir(bufnum);
	var seconds=BufDur.ir(bufnum)*bpm_source/bpm_target;
	var secondsPerSlice=seconds/slices;
	var beatPos=[
		TRand.kr(0,slicesPlus,changeBeatStart).floor,
		TRand.kr(0,slicesPlus,changeBeatStart).floor,
		TRand.kr(0,slicesPlus,changeBeatStart).floor,
		TRand.kr(0,slicesPlus,changeBeatStart).floor,
	];
	var combdelay = Demand.kr(changeBeat1,0,Drand([0,0,0,0,0,0,0,0,0,0,0,0,1],inf));
	var gverb = Demand.kr(changeBeat1,0,Drand([0,0,0,0,0,0,0,0,0,0,1],inf));

	rate = rate * Demand.kr(changeBeat1,0,Drand([1,1,1,1,1,1,-1],inf));
	rate = rate*BufRateScale.ir(bufnum)*bpm_target/bpm_source;


	// resetPosition to trigger
	resetPos=Demand.kr(changeBeatEighth,0,Dseq([
		beatPos[0],beatPos[0],
		beatPos[1],beatPos[1],
		beatPos[2],beatPos[2],
		beatPos[3],beatPos[3],
	],inf));
	resetPos=resetPos+Demand.kr(changeBeatEighth,0,Dseq([
		TRand.kr(0,slicesPlus,changeBeatStart).floor*(TRand.kr(0,1,changeBeatStart)>0.8375),
		TRand.kr(0,slicesPlus,changeBeatStart).floor*(TRand.kr(0,1,changeBeatStart)>0.8375),
		TRand.kr(0,slicesPlus,changeBeatStart).floor*(TRand.kr(0,1,changeBeatStart)>0.8375),
		TRand.kr(0,slicesPlus,changeBeatStart).floor*(TRand.kr(0,1,changeBeatStart)>0.8375),
		TRand.kr(0,slicesPlus,changeBeatStart).floor*(TRand.kr(0,1,changeBeatStart)>0.8375),
		TRand.kr(0,slicesPlus,changeBeatStart).floor*(TRand.kr(0,1,changeBeatStart)>0.8375),
		TRand.kr(0,slicesPlus,changeBeatStart).floor*(TRand.kr(0,1,changeBeatStart)>0.8375),
		TRand.kr(0,slicesPlus,changeBeatStart).floor*(TRand.kr(0,1,changeBeatStart)>0.8375),
		TRand.kr(0,slicesPlus,changeBeatStart).floor*(TRand.kr(0,1,changeBeatStart)>0.8375),
		TRand.kr(0,slicesPlus,changeBeatStart).floor*(TRand.kr(0,1,changeBeatStart)>0.8375),
		TRand.kr(0,slicesPlus,changeBeatStart).floor*(TRand.kr(0,1,changeBeatStart)>0.8375),
		TRand.kr(0,slicesPlus,changeBeatStart).floor*(TRand.kr(0,1,changeBeatStart)>0.8375),
		TRand.kr(0,slicesPlus,changeBeatStart).floor*(TRand.kr(0,1,changeBeatStart)>0.8375),
		TRand.kr(0,slicesPlus,changeBeatStart).floor*(TRand.kr(0,1,changeBeatStart)>0.8375),
		TRand.kr(0,slicesPlus,changeBeatStart).floor*(TRand.kr(0,1,changeBeatStart)>0.8375),
		TRand.kr(0,slicesPlus,changeBeatStart).floor*(TRand.kr(0,1,changeBeatStart)>0.8375),
	],inf));
	resetPos=resetPos%slices;
	resetPos=resetPos/slices*frames;

	// retrigger rate
	retriggerRate=Demand.kr(changeBeat4,0,Dseq([
		TRand.kr(1,1.999,changeBeatEnd).floor,
		TRand.kr(1,2.999,changeBeatEnd).floor,
		TRand.kr(1,3.999,changeBeatEnd).floor,
		TRand.kr(1,4.999,changeBeatEnd).floor,
		TRand.kr(1,1.999,changeBeatEnd).floor,
		TRand.kr(1,2.999,changeBeatEnd).floor,
		TRand.kr(1,3.999,changeBeatEnd).floor,
		TRand.kr(1,4.999,changeBeatEnd).floor,
	],inf));
	retriggerRate=retriggerRate*Demand.kr(changeBeat2,0,Dseq([
		TRand.kr(1,1.999,changeBeatEnd).floor,
		TRand.kr(1,2.999,changeBeatEnd).floor,
		TRand.kr(1,2.999,changeBeatEnd).floor,
		TRand.kr(1,1.999,changeBeatEnd).floor,
	],inf));
	retriggerRate=retriggerRate*Select.kr(numBeat%beatsInPhrase>(beatsInPhrase-5),[1,16/retriggerRate]); // at end of each phrase
	retriggerRate=retriggerRate*Select.kr(numBeat%beatsInPhrase>(beatsInPhrase-4),[1,TRand.kr(1,6.999,changeBeatStart).floor/2]); // at end of each phrase
	retriggerRate=retriggerRate*Select.kr(numBeat%beatsInPhrase>(beatsInPhrase-3),[1,TRand.kr(1,6.999,changeBeatStart).floor/2]); // at end of each phrase
	retriggerRate=retriggerRate*Select.kr(numBeat%beatsInPhrase>(beatsInPhrase-2),[1,TRand.kr(1,2.999,changeBeatStart).floor]); // at end of each phrase
	retriggerNum=(bpm_target/60*A2K.kr(mainPhase)/4*retriggerRate).floor%slices;
	retriggerTrig=Changed.kr(retriggerNum);

	// rate changes
	rate=rate*Lag.kr(TWChoose.kr(changeBeat1,[1,0.5,0.25,1.25],[0.9*be_normal,0.03,0.02,0.01],1));
	rate=rate*TWChoose.kr(changeBeat4,[1,-1],[0.8375*be_normal,0.05],1);
	rate=rate*Select.kr((numBeat%16<1)*(TRand.kr(0,1,changeBeat1)<0.75),[1,0.5]); // at end of each phrase

	// toggling
	aOrB=ToggleFF.kr(t_trig+retriggerTrig);
	crossfade=VarLag.ar(K2A.ar(aOrB),xfade,warp:\sine);

	posA=Phasor.ar(
		trig:(1-aOrB),
		rate:rate,
		end:BufFrames.ir(bufnum),
		resetPos:Latch.kr(resetPos,1-aOrB)
	);
	posB=Phasor.ar(
		trig:aOrB,
		rate:rate,
		end:BufFrames.ir(bufnum),
		resetPos:Latch.kr(resetPos,aOrB)
	);
	snd=(BufRd.ar(
		numChannels:2,
		bufnum:bufnum,
		phase:posA,
	)*crossfade)+(BufRd.ar(
		numChannels:2,
		bufnum:bufnum,
		phase:posB,
	)*(1-crossfade));

	snd=RLPF.ar(snd,EnvGen.kr(Env.new([130,45,130],[seconds/slices/4,seconds/slices*4]),
		// gate
		(numBeat%beatsInPhrase>(beatsInPhrase-4)) +
		(Trig.kr(TRand.kr(0,1,changeBeat2)>0.95,secondsPerSlice*2))
	).midicps,0.707);
	// snd=snd*EnvGen.kr(Env.new([1,0,1],[seconds/slices/4,seconds/slices*2]),numBeat%beatsInPhrase>(beatsInPhrase-5));

	doGate=Changed.kr(changeBeat1)*LFNoise0.kr(1)>0.9;
	snd=snd*EnvGen.kr(Env.new([1,1,0,1],[seconds/slices*0.5,seconds/slices*0.5,seconds/slices]),doGate);

	snd=Compander.ar(snd,snd,1,1-compression,1/4,0.01,0.1);
	snd=SelectX.ar(Lag.kr(TRand.kr(0,1,changeBeat4)>0.8)*doDecimate,[snd,Decimator.ar(snd,6000,6)]);

	// add in gating??

	//snd=Pan2.ar(snd,SinOsc.kr(bpm_target/60));
	snd=RHPF.ar(snd,60,0.707);

	snd = SelectX.ar(Lag.kr(combdelay),[snd, (0.5*snd)+
		Pan2.ar(CombN.ar(snd[0], 0.02, Rand(0.01,0.06), Rand(1,2)),-1,0.9) +
		Pan2.ar(CombN.ar(snd[1], 0.02, Rand(0.01,0.06), Rand(1,2)),1,0.9)
	]);

	snd = SelectX.ar(Lag.kr(gverb),[snd,FreeVerb2.ar(snd[0],snd[1],1,0.9,0.1)]);

	snd = Balance2.ar(snd[0],snd[1],pan+(Demand.kr(changeBeat1,0,
		Drand([0,0,0,0,0,0,0,0,1,1],inf)
	)*Demand.kr(changeBeat1,0,
		Drand([0.05,0.01,0,0,0,0,0.1,0.2,0.3,0.4,0.5,0,0,0,0,0,1],inf)
	)
	));

	Out.ar(out,snd*Lag.kr(amp,2)/2);
}).add;
SynthDef("kick", { |basefreq = 40, ratio = 6, sweeptime = 0.05, preamp = 1, amp = 1,
	decay1 = 0.3, decay1L = 0.8, decay2 = 0.15, clicky=0.0, out|
	var    fcurve = EnvGen.kr(Env([basefreq * ratio, basefreq], [sweeptime], \exp)),
	env = EnvGen.kr(Env([clicky,1, decay1L, 0], [0.0,decay1, decay2], -4), doneAction: Done.freeSelf),
	sig = SinOsc.ar(fcurve, 0.5pi, preamp).distort * env ;
	sig = (sig*amp).tanh!2;
	Out.ar(out,sig);
}).add;
SynthDef("out",{
	arg busin, vol=1,bpm_target;
	var rev;
	var mainPhase=In.ar(busin);
	var start=Impulse.kr(0);
	var numBeat=(bpm_target/60*A2K.kr(mainPhase)).floor;
	var changeBeat1=start+Changed.kr(numBeat);
	var changeBeatEighth=start+Changed.kr((bpm_target/60*A2K.kr(mainPhase)*2).floor);
	var changeBeat2=start+Changed.kr(numBeat%2<1);
	var changeBeat4=start+Changed.kr(numBeat%4<1);
	var changeBeat16=start+Changed.kr(numBeat%16<1);

	var snd  = In.ar(0,2)*Lag.kr(vol,1);
	var sndrev = snd * Lag.kr(Demand.kr(changeBeat1,0,Drand([0,0,0,0,0,0,0,0,0,1],inf)),2);
	rev = Fverb.ar(sndrev[0],sndrev[1],200,tail_density: LFNoise2.kr(1/3).range(50,90),decay: LFNoise2.kr(1/3).range(50,70));

	snd = SelectX.ar(0.5,[snd,rev]);

	snd = RHPF.ar(snd,60,0.303);

	snd = AnalogTape.ar(snd,0.8,0.8,0.8,2);

	ReplaceOut.ar(0,snd);
}).add;

b=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/amen_beats8_bpm172.wav");
c=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/amen_5c2d11c8_beats16_bpm170.flac");
//d=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/fss_ecv2_138_vocal_adlib_wet_soaring_arpeggio_high_Cm_keyCmin_bpm138_beats16_.flac");
d=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/nw_pr_122_kit_pluck_loop_septon_Cmin_key_bpm200_122_beats32_.flac");
e=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/plx_stp_132_synth_loop_waves_Cmin_key_bpm200_132_beats32_.flac");
f=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/RHC_120_vocal_loop_oldsoul_Cmin_key_bpm200_120_beats8_.flac");

o.free;
Routine {
	s.sync;
	~bpm_target = 180;
	~met=Bus.audio(s,1);
	x=Synth.head(s,"metronome",[\out,~met,\bpm_target,~bpm_target]);
	y=Synth.tail(s,"out",[\busin,~met,\bpm_target,~bpm_target]);

	o = OSCFunc({ |msg|
		var beat=msg[3];
		// (beat%64).postln;
		if (beat>31,{
			if (beat%8<1,{
				Synth.head(s,"kick",[\amp,0.7]);
			});
			if (beat%16<1,{
				Synth.head(s,"kick",[\amp,0.6]);
			});
			if ((beat%4<1)&&(rrand(0,100)<50),{
				Synth.head(s,"kick",[\amp,0.7]);
			});
			if (rrand(0,100)<10,{
				Synth.head(s,"kick",[\amp,0.5]);
			});
			if (beat%64>57,{
				Synth.head(s,"kick",[\amp,0.7]);
			});
		});
	}, '/beat');
	Routine{
		(60/~bpm_target*(32*5)).wait;
		y.set(\vol,0);
	}.play;
	~arp=Synth.after(x,"op",[\out,0,\busin,~met,\doDecimate,0,\bufnum,d,\bpm_source,200,\bpm_target,~bpm_target,\amp,0.9,\pan,0.0]);
	(60/~bpm_target*32).wait;
	~drums1=Synth.after(x,"op",[\out,0,\busin,~met,\bufnum,c,\bpm_source,170,\bpm_target,~bpm_target,\amp,0.75,\pan,0.0]);
	~vocals=Synth.after(x,"op",[\out,0,\busin,~met,\doDecimate,0,\bufnum,f,\bpm_source,100,\bpm_target,~bpm_target,\amp,0.8,\pan,0.0]);
	(60/~bpm_target*32).wait;
	~vocals.set(\amp,0);
	~arp.set(\amp,0.5);
	~drums1.set(\pan,-0.1);
	~drums1.set(\amp,0.85);
	Synth.after(x,"op",[\out,0,\busin,~met,\doDecimate,0,\bufnum,e,\bpm_source,200,\bpm_target,~bpm_target,\amp,0.85,\pan,0.0]);
	Synth.after(x,"op",[\out,0,\busin,~met,\bufnum,b,\bpm_source,172,\bpm_target,~bpm_target,\amp,0.9,\reverb,0.2,\pan,0.1]);
}.play;
)


