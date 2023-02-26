Pad {

	var server;
	var bufs;
	var oscs;
	var <syns;
	var win;
	var recording;
	var windata;

	*new {
		arg argServer;
		^super.new.init(argServer);
	}

	init {
		arg argServer;

		server=argServer;

		// initialize variables
		bufs = Dictionary.new();
		syns = Dictionary.new();
		oscs = Dictionary.new();
		windata = Array.newClear(128);
		recording = false;


		// effects
		SynthDef("effects",{
			arg amp=1.0;
			var snd=In.ar(0,2);
			var random_modulation={LFNoise2.kr(1/4)}!2;
			snd=HPF.ar(snd,30);
			// Fverb is better, release coming soon
			snd=SelectX.ar(random_modulation[0].range(0.1,0.5),[snd,Fverb.ar(snd[0],snd[1],50,decay:random_modulation[1].range(70,90))]);
			ReplaceOut.ar(0,snd*Lag.kr(amp));
		}).send(server);


		SynthDef("sine",{
			arg note=60,amp=0.5,out=0,attack=1,decay=1;
			var snd = Silent.ar(2);
			var pan = LFNoise2.kr(1/Rand(1,3)).range(-0.5,0.5);
			var env = EnvGen.ar(Env.perc(attack,decay,amp,[4,4]),doneAction:2);
			var detune = LFNoise2.kr(1/Rand(1,5)).range(0,0.1);


			// snd = snd + SinOsc.ar([note-0.06,note+0.05].midicps);
			snd = snd + Pulse.ar(
				freq:[note-detune,note+detune].midicps,
				width:SinOsc.kr(Rand(1,3),Rand(0,pi)).range(0.3,0.7)
			);
			snd = snd + Saw.ar(
				freq:[note-detune,note+detune].midicps,
			);

			snd = snd.fold(Rand(-1,0),Rand(0,1));

			snd = LockhartWavefolder.ar(snd[0] * LFNoise1.kr(1/4).range(1,10), 4) + ((LockhartWavefolder.ar(snd[1] * LFNoise1.kr(1/4).range(1,10), 4)) * [-1,1]);
			snd = RLPF.ar(snd, LinExp.kr(LFNoise2.kr(1/4).range(0.01,1),0.01,1,200,4000),LFNoise2.kr(1/4).range(0.1,1));
			//
			snd = AnalogVintageDistortion.ar(snd,0,1,0.1,0.1);

			snd = LeakDC.ar(snd);

			snd = RLPF.ar(snd,
				freq:note.midicps*LFNoise2.kr(1).range(3,6),
				rq:LFNoise2.kr(1/4).range(0.1,1)
			);



			snd = Balance2.ar(snd[0],snd[1],pan);

			SendReply.kr(Impulse.kr(25),"/position",[note,env,pan,detune]);

			Out.ar(out,snd*env);
		}).send(server);


		oscs.put("position",OSCFunc({ |msg|
			var oscRoute=msg[0];
			var synNum=msg[1];
			var dunno=msg[2];
			var note=msg[3].asInteger;
			var amplitude=msg[4];
			var pan=msg[5];
			var detune=msg[6];
			windata.put(note,[amplitude,pan,detune]);
		}, '/position'));

		server.sync;

		syns.put("fx",Synth.tail(server,"effects"));

		Routine {
			var timescale=8;
			inf.do({
				5.do{
					var note=Scale.major.degrees.choose+(12*rrand(3,5));
					var fraction=rrand(0,100)/100;
					if (windata.at(note).isNil,{
						Synth.before(syns.at("fx"),"sine",[
							\note,note,
							\amp,rrand(50,100)/100/10,
							\attack,fraction*timescale,
							\decay,(1-fraction)*timescale*2,
						]).onFree({
							windata.put(note,nil);
						});

					});
				};
				timescale.wait;
			});

		}.play;
		"done loading.".postln;
	}

	gui {
		arg height=350,width=800,spacing=20,padding=20;
		var w,a;
		var lastHeight=height;
		var lastWidth=width;
		var lastNum=0;
		var changed=true;
		var debounce=0;
		if (win.notNil,{
			// return early
			^nil
		});
		AppClock.sched(0,{
			var colors=[
				Color.fromHexString("#FFFAD7"),
				Color.fromHexString("#FCDDB0"),
				Color.fromHexString("#FF9F9F"),
				Color.fromHexString("#E97777"),
			];
			win = Window.new("web",Rect(0,0,width,height)).front;
			w=win;
			w.view.background_(colors[0]);
			w.drawFunc = {
				var num=0;
				var fillOrStroke=[\fill,\stroke,\stroke,\stroke,\stroke];
				windata.do{ arg v,note;
					if (v.notNil,{
						var amplitude=v[0];
						if (amplitude>0.0001,{
							var pan=v[1];
							var detune=v[2];
							var cc=Color.new255(99,89,133,255*amplitude);
							var x1=note.linlin(32,72,0,1)*w.bounds.width;
							var x2=(pan+0.5)*w.bounds.width;
							var color = colors[1+note.mod(3)];
							num = num + 1;
							color.alpha = (4*amplitude).clip(0,1);
							// draw waveform area
							// Pen.color = color;
							// Pen.line(Point(x1,-10),Point(x2,w.bounds.height+10));
							// Pen.width=detune.linlin(0,0.12,4,48);
							// Pen.fillStroke;


							Pen.color = color;
							Pen.moveTo(Point(w.bounds.width/2,w.bounds.height/2));
							Pen.addArc(
								Point(w.bounds.width/2,w.bounds.height/2),
								note.linlin(32,72,20,w.bounds.height/3),
								(pan+0.5)*2*pi,
								note.linlin(32,72,0,200).mod(32)/32*2*pi,
							);
							Pen.width=4*detune.linlin(0,0.12,1,8).asInteger;
							Pen.perform(fillOrStroke[note.mod(fillOrStroke.size)]);
						});


					});
				}
			};
		});

		AppClock.sched(0,{
			if (w.notNil,{
				if (w.isClosed.not,{
					w.refresh;
				});
			});
			0.04
		});

	}

	free {
		oscs.keysValuesDo({ arg k, val;
			val.free;
		});
		bufs.keysValuesDo({ arg k, val;
			val.free;
		});
		syns.keysValuesDo({ arg k, val;
			val.free;
		});
	}
}

