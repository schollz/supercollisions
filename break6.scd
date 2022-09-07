(
SynthDef("op",{
	arg out=0,amp=1.0,bufnum,bpm_source=170,bpm_target=180,t_trig=0,rate=1,xfade=0.005,slice_factor=1,compression=1,init_steps=0,be_normal=1;
	var snd,snd2,crossfade,posA,posB,aOrB,pos,retriggerNum,retriggerTrig,retriggerRate,doGate;
	var lpfOpen;
	var mainPhase=Phasor.ar(1,1/s.sampleRate,0,1000000);
	var slices=(BufDur.ir(bufnum)/(60/bpm_source)).round*slice_factor;
	var beatNum=(bpm_target/60*A2K.kr(mainPhase)).floor%slices;
	var measureNum=(bpm_target/60*A2K.kr(mainPhase)/4).floor%slices;
	var beat2Change=Changed.kr((bpm_target/60*A2K.kr(mainPhase)/2).floor%slices);
	var beatChange=Changed.kr(beatNum);
	var measureChange=Changed.kr(measureNum);

	var frames=BufFrames.ir(bufnum);
	var seconds=BufDur.ir(bufnum)*bpm_source/bpm_target;
	rate = rate*BufRateScale.ir(bufnum)*bpm_target/bpm_source;


	// position to trigger
	init_steps=((init_steps>0)*init_steps)+((init_steps<1)*slices);
	pos=(beatNum%init_steps.poll);
	pos=pos+TWChoose.kr(measureChange,[0,2,4,8,12]/16*slices,[1*be_normal,0.001,0.05,0.05,0.05],1);
	pos=pos+TWChoose.kr(beatChange,[0,LFNoise0.kr(1).range(1,slices).floor],[0.98*be_normal,0.2],1);
	pos=pos%slices;
	pos=pos/slices*frames;

	// retrigger rate
	retriggerRate=TWChoose.kr(measureChange,[1,2,4,8,16,32],[2*be_normal,0.1,0.05,0.025,0.025,0.005],1).poll;
	retriggerNum=(bpm_target/60*A2K.kr(mainPhase)/4*retriggerRate).floor%slices;
	retriggerTrig=Changed.kr(retriggerNum);


	// rate changes
	rate=rate*Lag.kr(TWChoose.kr(beatChange,[1,0.5,0.25,1.25],[0.9*be_normal,0.03,0.02,0.01],1));
	rate=rate*TWChoose.kr(beat2Change,[1,-1],[0.95*be_normal,0.05],1);

	// toggling
	aOrB=ToggleFF.kr(t_trig+retriggerTrig);
	crossfade=VarLag.ar(K2A.ar(aOrB),xfade,warp:\sine);
	snd=(PlayBuf.ar(
		numChannels:2,
		bufnum:bufnum,
		rate:rate,
		trigger:(1-aOrB),
		startPos:Latch.kr(pos,aOrB),
		loop:1,
	)*crossfade)+(PlayBuf.ar(
		numChannels:2,
		bufnum:bufnum,
		rate:rate,
		trigger:aOrB,
		startPos:Latch.kr(pos,1-aOrB),
		loop:1,
	)*(1-crossfade));

	snd=RLPF.ar(snd,EnvGen.kr(Env.new([130,30,130],[seconds/slices/4,seconds/slices*2]),Changed.kr(retriggerRate)*(retriggerRate>1)).midicps,0.707);
	snd=snd*EnvGen.kr(Env.new([1,0,1],[seconds/slices/4,seconds/slices*2]),Changed.kr(retriggerRate)*(retriggerRate>1));
	doGate=Changed.kr(beatChange)*LFNoise0.kr(1)>0.9;
	snd=snd*EnvGen.kr(Env.new([1,1,0,1],[seconds/slices*0.5,seconds/slices*0.5,seconds/slices]),doGate);
	snd=Compander.ar(snd,snd,1,1-compression,1/4,0.01,0.1);
	snd=SelectX.ar(Lag.kr(LFNoise0.kr(slices/seconds/4)>0.8),[snd,Decimator.ar(snd,6000,6)]);

	//snd=Pan2.ar(snd,SinOsc.kr(bpm_target/60));
	snd=RHPF.ar(snd,60,0.707);
	Out.ar(out,snd*Lag.kr(amp,2));
}).add;
)

b=Buffer.read(s,"/home/zns/Documents/supercollisions/row1/HGAT_120_full_drum_loop_granular_key_bpm120_beats16_.flac");
b=Buffer.read(s,"/home/zns/Documents/supercollisions/row1/HGAT_120_full_drum_loop_granular_key_bpm120_beats16_.flac");



b=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/amenbreak_bpm136.wav");
Synth("op",[\out,0,\bufnum,b,\bpm_source,136,\bpm_target,136,\amp,0.25,\init_steps,0,\be_normal,10]);


b.play
(
b=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/pad_bpm120_beats64.wav");
c=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/row1/HGAT_120_full_drum_loop_granular_key_bpm120_beats16_.flac");
d=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/fh_bs120_odybass_Am_keyAmin_bpm120_beats16_.flac");
e=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/brake_arp_keyAmin_bpm120_beats8_.flac");
)
d.play;


(
s.record;
Synth("op",[\out,0,\bufnum,b,\bpm_source,120,\bpm_target,136,\amp,0.25,\init_steps,64,\be_normal,10]);
x=Synth("op",[\out,0,\bufnum,c,\bpm_source,120,\bpm_target,136,\amp,0.0,\init_steps,4]);
y=Synth("op",[\out,0,\bufnum,d,\bpm_source,120,\bpm_target,136,\amp,0.0]);
z=Synth("op",[\out,0,\bufnum,e,\bpm_source,120,\bpm_target,136,\amp,0.0,\init_steps,4])
)
z.set(\amp,0.2)
(
x.set(\amp,0.6);
y.set(\amp,0.4);
z.set(\init_steps,0,\be_normal,1)
)
x.set(\be_normal,0)
x.set(\be_normal,1)
z.set(\amp,0.0)

x=Synth("op",[\out,0,\bufnum,c,\bpm_source,90,\bpm_target,90,\amp,0.5,\slices,1,\init_steps,16]);
x.set(\slices,16,\init_steps,8)
