// requires "Ube.sc" to be put into the Extensions directory
(
s.waitForBoot({
	var pairs;

	// define the "looper"

	SynthDef("looper",{
		// main arguments
		arg buf,tape,player,baseRate=1.0,amp=1.0,timescale=0.2;
		// variables to store UGens later
		var volume;
		var switch=0,snd,snd1,snd2,pos,pos1,pos2,posStart,posEnd,index;
		// store the number of frames and the duraiton
		var frames=BufFrames.kr(buf);
		var duration=BufDur.kr(buf);
		// LFO for the start point <-- tinker
		var lfoStart=SinOsc.kr(timescale/Rand(30,60),Rand(hi:2*pi)).range(1024,frames-10240);
		// LFO for the window lenth <-- tinker
		var lfoWindow=SinOsc.kr(timescale/Rand(60,120),Rand(hi:2*pi)).range(4096,frames/2);
		// LFO for the rate (right now its not an LFO)
		var lfoRate=baseRate;//*Select.kr(SinOsc.kr(1/Rand(10,30)).range(0,4.9),[1,0.25,0.5,1,2]);
		// LFO for switching between forward and reverse <-- tinker
		var lfoForward=Demand.kr(Impulse.kr(timescale/Rand(5,15)),0,Drand([0,1],inf));
		// LFO for the volume <-- tinker
		var lfoAmp=SinOsc.kr(timescale/Rand(10,30),Rand(hi:2*pi)).range(0.05,0.5);
		// LFO for the panning <-- tinker
		var lfoPan=SinOsc.kr(timescale/Rand(10,30),Rand(hi:2*pi)).range(-1,1);

		// calculate the final rate
		var rate=Lag.kr(lfoRate*(2*lfoForward-1),1)*BufRateScale.kr(buf);

		// modulate the start/stop
		posStart = lfoStart;
		posEnd = Clip.kr(posStart + lfoWindow,0,frames-1024);

		// LocalIn collects the a trigger whenever the playhead leaves the window
		switch=ToggleFF.kr(LocalIn.kr(1));

		// playhead 1 has a play position and buffer reader
		pos1=Phasor.ar(trig:1-switch,rate:rate,end:frames,resetPos:((lfoForward>0)*posStart)+((lfoForward<1)*posEnd));
		snd1=BufRd.ar(2,buf,pos1,1.0,4);

		// playhead 2 has a play position and buffer reader
		pos2=Phasor.ar(trig:switch,  rate:rate,end:frames,resetPos:((lfoForward>0)*posStart)+((lfoForward<1)*posEnd));
		snd2=BufRd.ar(2,buf,pos2,1.0,4);

		// current position changes according to the swtich
		pos=Select.ar(switch,[pos1,pos2]);

		// send out a trigger anytime the position is outside the window
		LocalOut.kr(
			Changed.kr(Stepper.kr(Impulse.kr(20),max:1000000000,
				step:(pos>posEnd)+(pos<posStart)
			))
		);

		// crossfade bewteen the two sounds over 50 milliseconds
		snd=SelectX.ar(Lag.kr(switch,0.05),[snd1,snd2]);

		// apply the volume lfo
		volume = amp*lfoAmp*EnvGen.ar(Env.new([0,1],[Rand(1,10)],4));

		// send data to the GUI
		SendReply.kr(Impulse.kr(25),"/position",[tape,player,posStart/frames,posEnd/frames,pos/frames,volume,(lfoPan+1)/2]);

		// do the panning
		snd=Balance2.ar(snd[0],snd[1],lfoPan);

		// final output
		Out.ar(0,snd*volume/5);
	}).send(s);


	// effects
	SynthDef("effects",{
		arg amp=1.0;
		var snd=In.ar(0,2);
		snd=HPF.ar(snd,80);
		// add some nice tape compression
		snd = AnalogTape.ar(snd,0.9,0.8,0.9,2);
		// add some reverb
		snd=SelectX.ar(LFNoise2.kr(1/3).range(0.5,0.8),[
			snd,
			Fverb.ar(snd[0],snd[1],50,decay:LFNoise2.kr(1/3).range(70,90))
		]);
		// // add some analog chewing
		// snd=SelectX.ar(LFNoise2.kr(1/3).range(0,1),[
		// 	snd,
		// 	AnalogChew.ar(snd);
		// ]);

		// replace the output with the effected output
		ReplaceOut.ar(0,snd*Lag.kr(amp));
	}).send(s);

	// load the ube class
	u=Ube.new(Server.default);

	// load a file into the tape
	u.loadTape(tape:1,filename:thisProcess.nowExecutingPath.dirname++"/kalimba.wav");

	// create players to play the tape
	u.playTape(tape:1,player:0,rate:1,db:0,timescale:1);
	u.playTape(tape:1,player:1,rate:0.5,db:3,timescale:1.0);
	u.playTape(tape:1,player:2,rate:0.25,db:6,timescale:1.0);
	u.playTape(tape:1,player:3,rate:0.125,db:9,timescale:1.0);
	u.playTape(tape:1,player:4,rate:2,db:-6,timescale:1.0);
	u.playTape(tape:1,player:5,rate:4,db:-12,timescale:1.0);

	// show gui
	u.gui;
});
)

// record another tape and play it
u.recordTape(tape:2,seconds:3,recLevel:0.5);
u.playTape(tape:2,player:5,rate:1,db:1,timescale:1.0);

