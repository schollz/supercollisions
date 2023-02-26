Sun {

	var server;
	var bufs;
	var oscs;
	var <syns;
	var win;
	var recording;
	var windata;
	var sectors;
	var max_note_num;

	*new {
		arg argServer;
		^super.new.init(argServer);
	}

	init {
		arg argServer;
		var scale=[];
		var nr={
			arg m,s;
			Pgauss.new(m,s,1).asStream.nextN(1)[0]
		};

		max_note_num = 48;
		10.do({ arg i;
			(Scale.major.degrees+((i+1)*12)).do({ arg v;
				if (scale.size<max_note_num) {
					scale=scale.add(v);
				}
			});
		});
		scale.postln;

		server=argServer;


		// initialize variables
		bufs = Dictionary.new();
		syns = Dictionary.new();
		oscs = Dictionary.new();
		sectors = Dictionary.new();

		sectors.put("avg",[10,7,5,2]);
		sectors.put("spread",[3,2,1,0.5]);
		//sectors.put("num",[2,3,4,2]);
	 	sectors.put("num",[1,2,3,1]);
		sectors.put("db",[6,-6,-9,-18]);
		sectors.postln;
		windata = Array.newClear(128);
		recording = false;


		// effects
		SynthDef("effects",{
			arg amp=1.0;
			var snd=In.ar(0,2);
			var random_modulation={LFNoise2.kr(1/4)}!4;
			snd=HPF.ar(snd,30);
			// Fverb is better, release coming soon
			snd=AnalogTape.ar(snd,0.9,0.9,0.8,2);
			// snd=SelectX.ar(LFNoise2.kr(1/5).range(0,1),[snd,AnalogVintageDistortion.ar(snd,0.1,0.1,oversample:2)]);
			snd=SelectX.ar(random_modulation[0].range(0.1,0.5),[snd,Fverb.ar(snd[0],snd[1],50,decay:random_modulation[1].range(70,90))]);
			ReplaceOut.ar(0,snd*Lag.kr(amp));
		}).send(server);


		SynthDef("sine",{
			arg note=60,amp=0.5,out=0,attack=1,decay=1;
			var snd = Silent.ar(2);
			var pan = LFNoise2.kr(1/Rand(3,6)).range(-0.5,0.5);
			var env = EnvGen.ar(Env.perc(attack,decay,amp,[4,4]),doneAction:2);
			var detune = LFNoise2.kr(1/Rand(1,5)).range(-0.1,0.1);

			// klank 
			// note = note + detune;
            // snd = snd + Klank.ar(`[[note.midicps,note.midicps*2,note.midicps*4,note.midicps*6],nil,[1,0.9,0.7,0.3]], PinkNoise.ar([0.05, 0.05]));
           	// snd = HPF.ar(snd,note.midicps/2);
           	// snd = LPF.ar(snd,note.midicps*8);

           	// sine
			// snd = snd + SinOsc.ar([note-detune,note+detune].midicps);

			// pwm
			snd = snd + PulseDPW.ar(
				freq:[note-detune,note+detune].midicps,
				width:SinOsc.kr(Rand(1,3),Rand(0,pi)).range(0.3,0.7)
			);

			// saw
			// snd = snd + SawDPW.ar(
			// 	freq:[note-detune,note+detune].midicps,
			// );

			// snd = snd.fold(Rand(-1,0),Rand(0,1));

			// snd = LockhartWavefolder.ar(snd[0] * LFNoise1.kr(1/4).range(1,10), 4) + ((LockhartWavefolder.ar(snd[1] * LFNoise1.kr(1/4).range(1,10), 4)) * [-1,1]);
			// snd = RLPF.ar(snd, LinExp.kr(LFNoise2.kr(1/4).range(0.01,1),0.01,1,200,4000),LFNoise2.kr(1/4).range(0.1,1));
			// snd = AnalogVintageDistortion.ar(snd,0,1,0.1,0.1);

			snd = LeakDC.ar(snd);

			snd = RLPF.ar(snd,
				freq:note.midicps*LFNoise2.kr(1).range(3,6),
				rq:LFNoise2.kr(1/4).range(0.1,1)
			);

			snd = Balance2.ar(snd[0],snd[1],pan);
			SendReply.kr(Impulse.kr(25),"/sunposition",[\sector.kr(0),note,env,pan,detune.abs]);
			Out.ar(out,snd*env/12);
		}).send(server);


		oscs.put("sunposition",OSCFunc({ |msg|
			var oscRoute=msg[0];
			var synNum=msg[1];
			var dunno=msg[2];
			var sector=msg[3].asInteger;
			var note=msg[4].asInteger;
			var amplitude=msg[5];
			var pan=msg[6];
			var detune=msg[7];
			windata.put(note,[sector,amplitude,pan,detune]);
		}, '/sunposition'));

		server.sync;

		syns.put("fx",Synth.tail(server,"effects"));

		4.do{ arg sector;
			var timescale=1;
			var notes=scale[(scale.size/4*(sector)).asInteger..(scale.size/4*(sector+1)).asInteger];
			[sector,notes].postln;
			sectors.at("num")[sector].do{
				Routine {
					inf.do{
						var note=notes.choose;
						var attack=(nr.value(sectors.at("avg")[sector],sectors.at("spread")[sector])*timescale).clip(0.01,30);
						var decay=(nr.value(sectors.at("avg")[sector],sectors.at("spread")[sector])*timescale).clip(0.01,30);

						if (windata.at(note).isNil,{
							[sector,note,attack,decay].postln;
							Synth.before(syns.at("fx"),"sine",[
								\sector,sector,
								\note,note,
								\amp,(sectors.at("db")[sector]+rrand(-3,3)).dbamp,
								\attack,attack,
								\decay,decay,
							]).onFree({
								windata.put(note,nil);
							});

						});
						((attack+decay)).wait;
					};
				}.play;
			};
		};

		"done loading.".postln;
	}

	gui {
		arg height=400,width=800,spacing=20,padding=20;
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
				var fillOrStroke=[\fill,\stroke,\fill,\fill,\fill,\stroke];
				windata.do{ arg v,note;
					if (v.notNil,{
						var sector=v[0];
						var amplitude=v[1];
						var pan=v[2];
						var detune=v[3];
						if (amplitude>0.0001,{
							var cc=Color.new255(99,89,133,255*amplitude);
							var x1=note.linlin(32,72,0,1)*w.bounds.width;
							var x2=(pan+0.5)*w.bounds.width;
							var y2=(pan+0.5)*w.bounds.height;
							var color = colors[1+note.mod(3)];
							var point1=Point(x2,-10);
							switch(sector,
								0, {point1=Point(x2,w.bounds.height+10)},
								1, {point1=Point(-10,y2)},
								2, {point1=Point(w.bounds.width+10,y2)}
							);
							num = num + 1;
							color.alpha = (amplitude*4).tanh;
							// draw waveform area
							Pen.joinStyle = 1;
							Pen.capStyle = 1;
							Pen.color = color;
							Pen.width=detune.linlin(0,0.12,4,16)*(w.bounds.width*w.bounds.height)/(600*600);
							Pen.line(point1,Point(w.bounds.width/2,w.bounds.height/2));
							Pen.fillStroke;

							Pen.moveTo(Point(w.bounds.width/2,w.bounds.height/2));
							Pen.addArc(
								Point(w.bounds.width/2,w.bounds.height/2),
								note.linlin(32,72,20,w.bounds.height/3),
								(2*pan)*2*pi,
								note.linlin(32,72,0,200).mod(32)/32*2*pi+0.3,
							);
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

