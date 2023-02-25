// requires "Ube.sc" to be put into the Extensions directory
(
s.waitForBoot({
	// s.record;
	Routine {
		SynthDef("effects",{
			var snd=In.ar(0,2);
			var random_modulation={VarLag.kr(LFNoise0.kr(1/4),4,warp:\sine)}!2;
			snd=HPF.ar(snd,120);
			// Fverb is better, release coming soon
			//snd=SelectX.ar(random_modulation[0].range(0.1,0.2),[snd,Fverb.ar(snd[0],snd[1],50,decay:random_modulation[1].range(70,90))]);
			snd=SelectX.ar(random_modulation[0].range(0.1,0.2),[snd,FreeVerb2.ar(snd[0],snd[1],1,0.7,0.3)]);
			ReplaceOut.ar(0,snd);
		}).send(s);
		s.sync;
		x=Synth.tail(s,"effects");

		// load the ube class
		b=Ube.new(Server.default);

		// load a file
		b.load(tape:1,filename:thisProcess.nowExecutingPath.dirname++"/kalimba.wav");

		// sync things
		s.sync;

		// play the tape with lots of players
		{
			var scale=Tuning.et12.ratios;
			var rates=[1.5,1.25,2,0.5,4,0.25,1,0.125];
			var dbs=[0,0,-6,-8,-6,-6,-4,0];
			// var rates=[scale[0],scale[4],scale[7],4,0.25];
			// var dbs=[0,0,0,0,6];
			rates.do({ arg v,i;
				b.play(tape:1,player:i,rate:rates[i],db:dbs[i],timescale:1.0);
			});
		}.play;

		// show gui (optional)
		// multiple tapes not shown
		b.gui;
	}.play;
});
)


// can add more players still still
b.play(tape:1,player:7,rate:1,db:1);
b.play(tape:1,player:8,rate:1,db:1);