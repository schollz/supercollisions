(
s.waitForBoot({

	Routine {
		SynthDef("effects",{
			var snd=In.ar(0,2);
			var random_modulation={VarLag.kr(LFNOise0.kr(1/4),4,warp:\sine)}!2;
			snd=HPF.ar(snd,120);
			// random reverb
			snd=SelectX.ar(random_modulation[0].range(0.1,0.2),[snd,Fverb.ar(snd[0],snd[1],50,decay:random_modulation[1].range(70,90))]);
			ReplaceOut.ar(0,snd);
		}).send(s);
		s.sync;
		x=Synth.tail(s,"effects");

		// load the barcode class
		b=Barcode2.new(Server.default);

		// load a file into barcode
		b.load(tape:1,filename:"/home/zns/Documents/supercollisions/kalimba.wav");
		// sync things
		s.sync;

		// play the tape
		{
			var rates=[1,1,2,0.5,4,0.25];
			var dbs=[0,0,-6,-12,-24,-36];
			rates.do({ arg v,i;
				b.play(tape:1,player:i,rate:rates[i],db:dbs[i]);
			});
		};
		// show gui
		b.gui;
	}.play;
});
)

