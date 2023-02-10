
(
b = Buffer.alloc(s,s.sampleRate*4,2);
c=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/beats16_bpm150_Ultimate_Jack_Loops_014__BPM_150_.wav");
)

(
x=SynthDef("quantizedbreaks",{
	arg out=0,amp=0.5,bpmsource=150,bpm=200,t_trig=0,bufnum,bufnumtemp;
	var playbuf,snd,rate,tempotrigger;
	tempotrigger=Impulse.kr(bpm/60);
	rate = bpm/bpmsource*BufRateScale.kr(bufnum);
	//rate = rate*Lag.kr(TChoose.kr(tempotrigger,[1,1,1,1,1,-1]),60/bpm*TChoose.kr(Dust.kr(1),[0,0,0,1,2,4]));
	playbuf=PlayBuf.ar(2,bufnum,rate,Impulse.kr(bpm/60/8),TChoose.kr(tempotrigger,(0..16)/16)*BufFrames.kr(bufnum),loop:1);
	snd=Breakcore.ar(bufnumtemp,playbuf,
		capturetrigger:Impulse.kr(bpm/60*TChoose.kr(tempotrigger,0.125*(1..32))),
		duration:TWChoose.kr(tempotrigger,[0.125/4,0.125/2,0.125,0.25,0.5,1,2,4,8],[0.25,0.5,1,1,3,3,3,3,4],1)*s.sampleRate*60/bpm,
		ampdropout:1
	);
	snd=HPF.ar(snd,100);
	snd=LPF.ar(snd,6000);
	Out.ar(out,snd*Lag.kr(amp,1))
}).play(s, [\out, 0, \bufnum, c.bufnum,\bufnumtemp,b.bufnum]);
)


x.set(\amp,1.0);
x.set(\amp,0.7,\t_trig,1);
x.set(\bpm,120);
s.peakCPU;
