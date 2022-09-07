(
SynthDef("op",{
	arg out=0,amp=1.0,bufnum,bpm_source=120,bpm_target=140,t_trig=0,rate=1,xfade=0.005,slice_factor=1,compression=0.3,init_steps=4,be_normal=1,reverb=0;
	var sig,snd,snd2,crossfade,aOrB,resetPos,retriggerNum,retriggerTrig,retriggerRate,doGate;
	var posA,posB;
	var beatsInPhrase=32;
	var mainPhase=Phasor.ar(1,1/s.sampleRate,0,1000000);
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
	var changeBeatStart=Trig.kr(numBeat%beatsInPhrase<1);
	var frames=BufFrames.ir(bufnum);
	var seconds=BufDur.ir(bufnum)*bpm_source/bpm_target;
	var secondsPerSlice=seconds/slices;
	var beatPos=[
		TRand.kr(0,slicesPlus,changeBeatStart).floor,
		TRand.kr(0,slicesPlus,changeBeatStart).floor,
		TRand.kr(0,slicesPlus,changeBeatStart).floor,
		TRand.kr(0,slicesPlus,changeBeatStart).floor,
	];
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
	retriggerRate=retriggerRate*Select.kr(numBeat%beatsInPhrase>(beatsInPhrase-2),[1,TRand.kr(1,6.999,changeBeatStart).floor/2]); // at end of each phrase
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
		rate:rate.abs,
		end:BufFrames.ir(bufnum),
		resetPos:Latch.kr(resetPos,1-aOrB)
	);
	posB=Phasor.ar(
		trig:aOrB,
		rate:rate.abs,
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

	snd=RLPF.ar(snd,EnvGen.kr(Env.new([130,50,130],[seconds/slices/4,seconds/slices*4]),
		// gate
		(numBeat%beatsInPhrase>(beatsInPhrase-5)) +
		(Trig.kr(TRand.kr(0,1,changeBeat2)>0.95,secondsPerSlice*2))
	).midicps,0.707);
	// snd=snd*EnvGen.kr(Env.new([1,0,1],[seconds/slices/4,seconds/slices*2]),numBeat%beatsInPhrase>(beatsInPhrase-5));
	// doGate=Changed.kr(changeBeat1)*LFNoise0.kr(1)>0.9;
	// snd=snd*EnvGen.kr(Env.new([1,1,0,1],[seconds/slices*0.5,seconds/slices*0.5,seconds/slices]),doGate);
	snd=Compander.ar(snd,snd,1,1-compression,1/4,0.01,0.1);
	snd=SelectX.ar(Lag.kr(TRand.kr(0,1,changeBeat4)>0.8),[snd,Decimator.ar(snd,6000,6)]);

	//snd=Pan2.ar(snd,SinOsc.kr(bpm_target/60));
	snd=RHPF.ar(snd,60,0.707);

	sig = snd/10;
	sig = DelayN.ar(sig, 0.03, 0.03);
	sig = CombN.ar(sig, 0.1, {Rand(0.01,0.099)}!32, 4);
	sig = SplayAz.ar(2, sig);
	sig = LPF.ar(sig, 1500);
	5.do{sig = AllpassN.ar(sig, 0.1, {Rand(0.01,0.099)}!2, 3)};
	sig = LPF.ar(sig, 1500);
	sig = LeakDC.ar(sig);

	snd=SelectX.ar(reverb,[snd,sig]);

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
)

Synth("op",[\out,0,\bufnum,b,\bpm_source,120,\bpm_target,136,\amp,1,\init_steps,0,\be_normal,1]);

b=Buffer.read(s,"/home/zns/Documents/supercollisions/120/Dennis Coffey - Ride Sally Ride (part1)__beats16_bpm120.wav");
b.play

b=Buffer.read(s,"/home/zns/Documents/supercollisions/row1/HGAT_120_full_drum_loop_granular_key_bpm120_beats16_.flac");
b=Buffer.read(s,"/home/zns/Documents/supercollisions/row1/HGAT_120_full_drum_loop_granular_key_bpm120_beats16_.flac");



b=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/amenbreak_bpm136.wav");


(
w = Window.new("soundfile test", Rect(200, 300, 740, 300));
a = SoundFileView.new(w, Rect(20,20, 700, 260));

f = SoundFile.new;
f.openRead(thisProcess.nowExecutingPath.dirname++"/amenbreak_bpm136.wav");

a.soundfile = f;
a.read(0, f.numFrames);

a.timeCursorOn = false;
a.timeCursorColor = Color.red;
a.timeCursorPosition = 2050;
a.drawsWaveForm = true;
a.gridOn = false;
a.gridResolution = 0.2;

w.front;
)

a.setSelectionColor(0, Color.red);  // set...( index, value )
a.setSelectionStart(0, 0);
a.setSelectionSize(0, b.numFrames/64);


b.play

c=Buffer.read(s,"/home/zns/Documents/supercollisions/136/James Brown - Cold Sweat Live (part7)__beats8_bpm136.wav");

(
b=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/pad_bpm120_beats64.wav");
c=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/HGAT_120_full_drum_loop_granular_key_bpm120_beats16_.flac");
d=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/fh_bs120_odybass_Am_keyAmin_bpm120_beats16_.flac");
e=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/brake_arp_keyAmin_bpm120_beats8_.flac");
)
b.play
c.play
d.play
e.play
d.play;


(
// s.record;
w=Synth("op",[\out,0,\bufnum,b,\bpm_source,120,\bpm_target,136,\amp,0.4,\init_steps,64,\be_normal,10,\reverb,0.7]);
x=Synth("op",[\out,0,\bufnum,c,\bpm_source,120,\bpm_target,136,\amp,0.0,\init_steps,4]);
y=Synth("op",[\out,0,\bufnum,d,\bpm_source,120,\bpm_target,136,\amp,0.0]);
z=Synth("op",[\out,0,\bufnum,e,\bpm_source,120,\bpm_target,136,\amp,0.0,\be_normal,0.5]);
Routine {
	inf.do{
		Synth("kick");
		(60/136*2).wait;
	}
}.play;
)
w.set(\reverb,0.7,\amp,0.5)
z.set(\amp,0.4)
(
w.set(\bpm_source,120,\bpm_target,136);
x.set(\amp,0.6);
y.set(\amp,0.4);
z.set(\amp,0.2 );
)
(
x.set(\amp,0.0);
y.set(\amp,0.2);
z.set(\amp,0);
)

x.set(\be_normal,0)
x.set(\be_normal,1)
z.set(\amp,0.0)

x=Synth("op",[\out,0,\bufnum,c,\bpm_source,90,\bpm_target,90,\amp,0.5,\slices,1,\init_steps,16]);
x.set(\slices,16,\init_steps,8)
