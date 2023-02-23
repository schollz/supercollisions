(
s.waitForBoot({

	var height=400;
	var width=500;
	var spacing=20;
	var padding=50;
	d=Array.newClear(6);
	w = Window.new("barcode",Rect(100,500,width,height)).front;
	w.view.background_(Color.gray(0.95,1));
	w.drawFunc = {
		d.do{ arg v,i;
			if (v.notNil,{
				// set the Color
				Pen.color = Color.blue((v[3]+0.1).tanh,(v[3]+0.1).tanh);
				Pen.addRect(
					Rect(v[0]*(w.bounds.width-padding)+(padding/2), padding/2+(i*((w.bounds.height-padding)/d.size)), (v[1]-v[0])*(w.bounds.width-padding), w.bounds.height/d.size-spacing)
				);
				Pen.perform(\fill);

				Pen.color = Color.white(0.5,0.5);
				Pen.addRect(
					Rect(v[2]*(w.bounds.width-padding)+(padding/2), padding/2+(i*((w.bounds.height-padding)/d.size)), 4, w.bounds.height/d.size-spacing)
				);
				Pen.perform(\fill);

			});
		}
	};

{ while { w.isClosed.not } { w.refresh; 0.04.wait; } }.fork(AppClock);

	o = OSCFunc({ |msg|
		var oscRoute=msg[0];
		var synNum=msg[1];
		var dunno=msg[2];
		var player=msg[3].asInteger;
		var posStart=msg[4];
		var posEnd=msg[5];
		var pos=msg[6];
		var volume=msg[7];
		d.put(player,[posStart,posEnd,pos,volume]);
	}, '/position');


	Routine {



		SynthDef("effects",{
			var snd=In.ar(0,2);
			var snd2;
			// var snd2=snd*VarLag.kr(LFNoise0.kr(4),1/4,warp:\sine).range(1,4);
			// snd2=AnalogTape.ar(snd2,0.9,0.9,0.7);
			// snd2=AnalogChew.ar(snd2,VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1),Trig.kr(Dust.kr(0.5),LFNoise0.kr(1).range(0.5,1.8)),VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1));
			// snd2=AnalogDegrade.ar(snd2,Trig.kr(Dust.kr(0.5),LFNoise0.kr(1).range(0.1,0.3)),Trig.kr(Dust.kr(0.5),LFNoise0.kr(1).range(0.1,0.3)),VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1),VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1));
			// snd2=AnalogLoss.ar(snd2,VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1),VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1),VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1),VarLag.kr(LFNoise0.kr(1),1,warp:\sine).range(0,1));
			snd2=snd;
			snd2=HPF.ar(snd2,120);
			snd2=SelectX.ar(0.15,[snd2,Fverb.ar(snd2[0],snd2[1],50,decay:VarLag.kr(LFNoise0.kr(1/4),4,warp:\sine).range(70,90))]);
			ReplaceOut.ar(0,snd2);
		}).send(s);
		s.sync;
		x=Synth.tail(s,"effects");


		b=Barcode2.new(Server.default);
		b.load(1,"/home/zns/Documents/supercollisions/kalimba.wav");
		s.sync;
		b.play(1,0,1,1);
		b.play(1,1,1,0.5);
		b.play(1,2,2,0.25);
		b.play(1,3,0.25,2);
		b.play(1,4,4,0.125);
		b.play(1,5,0.125,0.05);


	}.play;
});
)

w.bounds.width
Rect