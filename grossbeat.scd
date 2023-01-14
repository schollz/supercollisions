(
{
	var mu=0.0001;
	// EnvGen.ar(Env.circle([0,0,1.neg,1.neg,2.neg,2.neg,3.neg,3.neg],[1-mu,mu,1-mu,mu,1-mu,mu],[0,0,0,0,0,0,0,0]),1,timeScale:1/8);
	EnvGen.ar(Env.circle([0,0,0.25.neg,0.25.neg,0.5.neg,0.5.neg,0.75.neg,0.75.neg,1.neg,1.neg,2.neg,2.neg,3.neg,3.neg],[0.25-mu,mu,0.25-mu,mu,0.25-mu,mu,0.25-mu,mu,1-mu,mu,1-mu,mu,1-mu,mu],[0,0,0,0,-4,-4,-1,-4,-4,4,4]),1,timeScale:1/8);
	// EnvGen.ar(Env.circle([0,1.neg,1.neg,2.neg,2.neg,3.neg,3.neg],[1,1-mu,mu,1-mu,mu],[-4,0,0,0,0,0,0,0]),1,timeScale:1/8);
}.plot(1)
)
(
{
	var mu=0.0001;
	// EnvGen.ar(Env.circle([0,0,1.neg,1.neg,2.neg,2.neg,3.neg,3.neg],[1-mu,mu,1-mu,mu,1-mu,mu],[0,0,0,0,0,0,0,0]),1,timeScale:1/8);
	EnvGen.ar(Env.circle([0,0,1,0,1,1,1,0,1,0,1],[0.25-mu,mu,0.25-mu,mu,0.25-mu,mu,0.25-mu,mu,1-mu,mu,1,1-mu,mu],[0,0,0,0,4,4,1,4,4,4,4]),1,timeScale:1/8);
	// EnvGen.ar(Env.circle([0,1.neg,1.neg,2.neg,2.neg,3.neg,3.neg],[1,1-mu,mu,1-mu,mu],[-4,0,0,0,0,0,0,0]),1,timeScale:1/8);
}.plot(1)
)


(
s.waitForBoot({
	SynthDef("grossbeat",{
		arg buf,bufrec;
		var snd;
		var bpm=136;
		var secondsPerBeat=60/bpm;
		var samplesPerBeat=s.sampleRate*secondsPerBeat;
		var mu=0.00001;
		var posBeat=EnvGen.ar(
			Env.circle([0,0,0.25.neg,0.25.neg,0.5.neg,0.5.neg,0.75.neg,0.75.neg,1.neg,1.neg,2.neg,2.neg,3.neg,3.neg],[0.25-mu,mu,0.25-mu,mu,0.25-mu,mu,0.25-mu,mu,1-mu,mu,1-mu,mu,1-mu,mu],[0,0,0,0,-4,-4,-1,-4,-4,4,4])
		,1,timeScale:secondsPerBeat*2);
		var posRec=Phasor.ar(1,end:BufFrames.ir(bufrec));
		var input=PlayBuf.ar(2,buf,BufRateScale.ir(buf),loop:1);
		var posGross=(posRec+(posBeat*samplesPerBeat)-1).mod(BufFrames.ir(bufrec));
		BufWr.ar(input,bufrec,posRec);
		snd=BufRd.ar(2,bufrec,posGross.poll,interpolation:4);
		// snd=snd*EnvGen.ar(Env.circle([0,0,1,0,1,1,1,0,1,0,1],[0.25-mu,mu,0.25-mu,mu,0.25-mu,mu,0.25-mu,mu,1-mu,mu,1,1-mu,mu],[0,0,0,0,4,4,1,4,4,4,4]),1,timeScale:secondsPerBeat*2);
		Out.ar(0,SelectX.ar(MouseX.kr(0,1).poll,[input,snd]));
	}).send(s);
	s.sync;
	~bufGross=Buffer.alloc(s,s.sampleRate*60,2);
	s.sync;
	Buffer.read(Server.default, thisProcess.nowExecutingPath.dirname++"/amenbreak_bpm136.wav", action: {arg buf;
		Synth("grossbeat",[\buf,buf,\bufrec,~bufGross.bufnum]);
	});
});
)


~bufGross.play