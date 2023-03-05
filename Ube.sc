Ube {

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



		// basic players
		SynthDef("recorder",{
			arg buf,recLevel=1.0,preLevel=0.0;
			RecordBuf.ar(SoundIn.ar([0,1]),buf,0.0,recLevel,preLevel,loop:0,doneAction:2);
		}).send(server);


		oscs.put("position",OSCFunc({ |msg|
			var oscRoute=msg[0];
			var synNum=msg[1];
			var dunno=msg[2];
			var tape=msg[3].asInteger;
			var player=msg[4].asInteger;
			var posStart=msg[5];
			var posEnd=msg[6];
			var pos=msg[7];
			var volume=msg[8];
			var pan=msg[9];
			windata.put(player,[tape,posStart,posEnd,pos,volume,pan]);
		}, '/position'));

		server.sync;

		syns.put("fx",Synth.tail(server,"effects"));

		"done loading.".postln;
	}

	playTape {
		arg tape=1,player=1,rate=1.0,db=0.0,timescale=1;
		var amp=db.dbamp;
		var tapeid="tape"++tape;
		var playid="player"++player++tapeid;

		if (bufs.at(tapeid).isNil,{
			("[ube] cannot play empty tape"+tape).postln;
			^0
		});
		("[ube] player"+player+"playing tape"+tape).postln;

		syns.put(playid,Synth.head(server,"looper",[\tape,tape,\player,player,\buf,bufs.at(tapeid),\baseRate,rate,\amp,amp,\timescale,timescale]).onFree({
			("[ube] player"+player+"finished.").postln;
		}));
		NodeWatcher.register(syns.at(playid));
	}

	loadTape {
		arg tape=1,filename="";
		var tapeid="tape"++tape;
		if (filename=="",{
			("[ube] error: need to provide filename").postln;
			^nil
		});
		bufs.put(tapeid,Buffer.read(server,filename,action:{ arg buf;
			("[ube] loaded"+tape+filename).postln;
		}));
		server.sync;
	}

	recordTape {
		arg tape=1,seconds=30,recLevel=1.0;
		var tapeid="tape"++tape;
		Buffer.alloc(server,server.sampleRate*seconds,2,{ arg buf;
			// silence all output to prevent feedback?
			syns.at("fx").set(\amp,0);
			recording=true;

			// initiate recorder
			("[ube] record"+buf.bufnum+tape+seconds+recLevel).postln;
			syns.put("record"++tape,Synth.head(server,"recorder",[\buf,buf,\recLevel,recLevel,\preLevel,0]).onFree({
				("[ube] recording to buf"+buf.bufnum+"finished.").postln;
				// update the buffers in synths
				syns.keysValuesDo({ arg k,v;
					if (k.contains(tapeid),{
						("[ube] updating"+k+"with buffer"+buf.bufnum).postln;
						syns.at(k).set(\buf,buf);
					});
				});
				// turn on the main fx again
				syns.at("fx").set(\amp,1);
				recording=false;
				// update the buffer
				if (bufs.at(tapeid).notNil,{
					bufs.at(tapeid).free;
				});
				bufs.put(tapeid,buf);
			}));
			NodeWatcher.register(syns.at("record"++tape));

		});

	}

	gui {
		arg height=800,width=800,spacing=20,padding=20;
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
			win = Window.new("ube",Rect(100,500,width,height)).front;
			w=win;
			w.view.background_(Color.new255(236,242,255));
			w.drawFunc = {
				var num=1;
				var x,availableHeight,h;
				windata.do{ arg v;
					if (v.notNil,{
						num=num+1;
					});
				};
				x=(w.bounds.width-(2*padding));
				availableHeight=((w.bounds.height-(padding*2))/num);
				h=(availableHeight-spacing);
				if (recording,{
					debounce=10;
				});
				if (lastWidth!=w.bounds.width,{
					debounce=10;
				});
				if (lastHeight!=w.bounds.height,{
					debounce=10;
				});
				if (lastNum!=num,{
					debounce=10;
				});
				lastNum=num;
				lastHeight=w.bounds.height;
				lastWidth=w.bounds.width;
				if (debounce==1,{
					var tapeid=nil;
					debounce=0;
					if (windata.size>0,{
						tapeid="tape"++windata[0][0].asInteger;
						tapeid=tapeid.asString;
					});
					if (tapeid.notNil,{
						tapeid="tape1";
						if (a.notNil,{
							a.close;
						});
						a = SoundFileView.new(w, Rect(padding,padding, x, h));
						bufs.at(tapeid).loadToFloatArray(0, -1, {|floatArray|
							AppClock.sched(0,{
								a.setData(floatArray*1.5,4096,0,1,bufs.at(tapeid).sampleRate);
								a.refresh;
							});
						});
						a.gridOn = false;
						a.timeCursorOn = false;
						a.drawsCenterLine  = false;
						a.drawsBoundingLines = false;
						a.peakColor=Color.new255(99,89,133,150);
						a.rmsColor=Color.new255(99,89,133,60);
						a.background_(Color.new255(236,242,255,0));
					});

				},{
					if (debounce>0,{
						debounce=debounce-1;
					});
				});
				windata.do{ arg v,j;
					var i=j+1;
					if (v.notNil,{
						var y=padding+(i*availableHeight);
						var posStart=v[1];
						var posEnd=v[2];
						var posWidth=(v[2]-v[1]);
						var pos=v[3];
						var volume=v[4];
						var pan=v[5];
						var volume01=volume.ampdb.linlin(-96,12,0,1)+0.001;
						var cc=Color.new255(99,89,133,255*volume01);
						// var cc=Color.new255(96,150,180,255*volume01);

						// draw waveform area
						Pen.color = cc;
						Pen.addRect(
							Rect.new(posStart*x+(padding),y,posWidth*x, h)
						);
						Pen.perform(\fill);

						// draw playhead
						Pen.color = Color.white(0.5,0.5);
						Pen.addRect(
							Rect(pos*x+(padding)-2, y, 4, h)
						);
						Pen.perform(\fill);

						// draw pan symbol
						Pen.color = cc;
						Pen.addRect(
							Rect(pan*x+(padding)-8,y,16,h)
						);
						Pen.perform(\fill);

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

