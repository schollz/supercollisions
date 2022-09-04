(
b=Buffer.read(s,"/home/zns/Documents/supercollisions/break/lib/amens/rAmen_Break_140_beats16_bpm_key_bpm140_beats16_.flac");
)
b=Buffer.read(s,"/home/zns/Documents/supercollisions/break/lib/amens/Bpm170_Amen01_Break_170_PL-0004_key_bpm170_beats16_.flac");
c=Buffer.read(s,"/home/zns/Documents/supercollisions/break/lib/amens/MLEUC_break_loop_amenclean_140_key_bpm140_beats16_.flac");
b=Buffer.read(s,"/home/zns/Documents/supercollisions/break/lib/amens/ttb_drum_loop_break_amen_138__beats32_bpm138_beats32_.flac");
b=Buffer.read(s,"/home/zns/Documents/supercollisions/break/lib/amens/ELIMINATE_MDSTP_drum_loop_amenbreak_top_150_key_bpm150_beats16_.flac");

b=Buffer.read(s,"/home/zns/Documents/supercollisions/row1/PMJO_Vocal_Sessions_New_Plan_120_Am_Vocal_Atmosphere_05_keyAmin_bpm120_beats32_.flac");





(
SynthDef("op",{
	arg out=0,amp=1.0,bufnum,bpm_source=170,bpm_target=180,t_trig=0,rate=1,xfade=0.005,compression=1,slices=16,init_steps=4;
	var snd,snd2,crossfade,posA,posB,aOrB,pos,retriggerNum,retriggerTrig,retriggerRate,doGate;
	var lpfOpen;
	var mainPhase=Phasor.ar(1,1/s.sampleRate,0,1000000);
	var beatNum=(bpm_target/60*A2K.kr(mainPhase)*slices/16).floor%slices;
	var measureNum=(bpm_target/60*A2K.kr(mainPhase)*slices/16/4).floor%slices;
	var beatChange=Changed.kr(beatNum);
	var measureChange=Changed.kr(measureNum);

	var frames=BufFrames.ir(bufnum);
	var seconds=BufDur.ir(bufnum)*bpm_source/bpm_target;
	rate = rate*BufRateScale.ir(bufnum)*bpm_target/bpm_source;


	// position to trigger
	pos=(beatNum%init_steps);
	pos=pos+TWChoose.kr(measureChange,[0,2,4,8,12]/16*slices,[0.3,0.05,0.3,0.3,0.3],1);
	pos=pos+TWChoose.kr(beatChange,[0,LFNoise0.kr(1).range(1,slices).floor],[0.98,0.02],1);
	pos=pos%slices;
	pos=pos/slices*frames;

	// retrigger rate
	retriggerRate=TWChoose.kr(measureChange,[1,2,4,8,16]/16*slices,[0.8,0.1,0.05,0.025,0.025],1);
	retriggerNum=(bpm_target/60*A2K.kr(mainPhase)*retriggerRate).floor%slices;
	retriggerTrig=Changed.kr(retriggerNum);

	// rate changes
	rate=rate*Lag.kr(TWChoose.kr(beatChange,[1,0.5,0.25,1.25],[0.9,0.1,0.02,0.01],1));
	rate=rate*TWChoose.kr(beatChange,[1,-1],[0.9,0.1],1);

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
	doGate=Changed.kr(beatChange)*LFNoise0.kr(1).poll>0.1;
	snd=snd*EnvGen.kr(Env.new([1,1,0,1],[seconds/slices*0.5,seconds/slices*0.5,seconds/slices]),doGate).poll;
	// snd=SelectX.ar(Lag.kr(Trig.kr(doGate,seconds/16)),[snd,0.5*snd+FreeVerb.ar(snd,mix:0.33,damp:0.1)]);
	//
	snd=Compander.ar(snd,snd,1,1-MouseX.kr(),1/4,0.01,0.1);
	snd=SelectX.ar(MouseY.kr(),[snd,Decimator.ar(snd,6000,6)]);

	snd=RHPF.ar(snd,60,0.707);
	Out.ar(out,snd*amp);
}).add;
)

b.play
x=Synth("op",[\out,0,\bufnum,b,\bpm_source,120,\bpm_target,120,\amp,0.5,\slices,16]);
x.set(\slices,16)