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
	var synName;
	var synOutput;
	var scale;

	*new {
		arg argServer, argSynName, argSynOutput, argScale, argTimes, argNums;
		^super.new.init(argServer, argSynName, argSynOutput, argScale, argTimes, argNums);
	}

	init {
		arg argServer, argSynName, argSynOutput, argScale, argTimes, argNums;
		var scale=[];
		var nr={
			arg m,s;
			Pgauss.new(m,s,1).asStream.nextN(1)[0]
		};

		synName = argSynName;
		synOutput = argSynOutput;

		max_note_num = 48;
		10.do({ arg i;
			(argScale.degrees+((i+1)*12)).do({ arg v;
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

		sectors.put("avg",argTimes);
		//sectors.put("num",[2,3,4,2]);
		sectors.put("num",argNums);
		sectors.put("db",[9,-3,-9,-24]);
		sectors.postln;
		windata = Array.newClear(128);
		recording = false;

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

		syns.put("fx",Synth.tail(server,synOutput));

		4.do{ arg sector;
			var timescale=1;
			var notes=scale[(scale.size/4*(sector)).asInteger..(scale.size/4*(sector+1)).asInteger];
			[sector,notes].postln;
			sectors.at("num")[sector].do{
				Routine {
					inf.do{
						var note=notes.choose;
						var attack=(nr.value(sectors.at("avg")[sector],sectors.at("avg")[sector]*rrand(0.2,0.3))*timescale).clip(0.01,30);
						var decay=(nr.value(sectors.at("avg")[sector],sectors.at("avg")[sector]*rrand(0.2,0.3))*timescale).clip(0.01,30);

						if (windata.at(note).isNil,{
							[sector,note,attack,decay].postln;
							Synth.before(syns.at("fx"),synName,[
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

