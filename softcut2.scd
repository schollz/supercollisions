(
s.waitForBoot({

	SynthDef(\softcuthead,{
		arg buf, gate=1,
		phase_out= -1, trig_out= -1, trig_in = -1,t_trig=0,feedback=0.8,
		amp=0.2, rec=0.0, pre=0.0,
		rate=1, ratelag=0.1,
		start=0, end=1, fade=0.005, loop=1,
		fadeRec=0.1, fadePre = 0.1, recRun=0, offset = 0,
		preLag=0.0005, recLag=0.0005, envTimeScale = 1.0, done=0;

		var snd, phase, tr, delayed;
		var brs;
		var cutfade;
		var trig;
		var sin;
		var aenv;
		var theta=2*pi*413/s.sampleRate;
		var alpha=(theta)/(theta+1);
		var coef=1-alpha;

		pre=MouseX.kr(0,1.1).poll;
		rate =4;

		brs = BufRateScale.kr(buf);

		trig = InTrig.kr(trig_in);
		snd = Saw.ar(440)*EnvGen.ar(Env.perc(),Impulse.kr(1));
		snd = RLPF.ar(snd,MouseY.kr(20,9000,1),1/1.1);
		// snd = snd + LocalIn.ar(1);

		pre = Lag.ar(K2A.ar(pre), preLag);
		rec = Lag.ar(K2A.ar(rec), recLag);
		rate = Lag.ar(K2A.ar(rate), ratelag);
		cutfade =  SoftCutHead.ar(buf,snd/2,rec,pre,rate*brs,0.0,trig,start,end,fade,loop,fadeRec,fadePre,recRun,offset);
		phase = cutfade[0];
		tr = cutfade[1];
		delayed = cutfade[2];
		[phase,tr].poll;
		// LocalOut.ar(feedback * OnePole.ar(delayed,coef));


		snd=OnePole.ar(snd+delayed,coef);
		snd = RLPF.ar(snd,5800,1);

		Out.ar(0,snd);

	}).send(s);
	s.sync;
	~buf=Buffer.alloc(s, s.sampleRate * 10.0, 1);
	s.sync;
	postln("buffer samplerate: " ++ ~buf.sampleRate ++  " ; duration: " ++ ~buf.duration);

	if(~buf.sampleRate != s.sampleRate, {
		postln("WARNING: buffer and server have different sample rates. recording over this buffer may produce unwanted artifacts. ");
	});

	~start_pos = 1;
	~end_pos = 2;
	~fade_dur = 0.1;
	~loop_dur = ~end_pos - ~start_pos;

	~phase_rd_b= Bus.audio(s, 1);
	~trig_rd_b= Bus.audio(s, 1);

	// touching this control bus will trigger playback
	~loop_trig_b = Bus.control(s, 1);

	~loop_s = Synth.new(\softcuthead, [
		\buf, ~buf.bufnum,
		\start, ~start_pos, \end, ~end_pos,
		\phase_out, ~phase_rd_b.index,
		\trig_out, ~trig_rd_b.index,
		\trig_in, ~loop_trig_b.index,
		\fade, ~fade_dur,
		\pre, 0.0, \rec, 1.0, \rate, 4
	], s);

	~loop_trig_b.set(1);
	~loop_s.set(\recRun,1);
});
)
~loop_s.set(\rate,4,\recLag,2,\feedback,0.0)
~loop_s.set(\rate,4,\recLag,2,\feedback,2)

~loop_s.set(\pre,0.7,\rate,2,\recLag,2)
// is strange...
~buf.plot

