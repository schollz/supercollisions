Ube {

	var server;
	var bufs;
	var oscs;
	var syns;
	var win;
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

		// basic players
		SynthDef("recorder",{
			arg buf,recLevel=1.0,preLevel=0.0;
			RecordBuf.ar(SoundIn.ar([0,1]),buf,0.0,recLevel,preLevel,loop:0,doneAction:2);
		}).send(server);

		SynthDef("looper",{
			arg buf,tape,player,baseRate=1.0,amp=1.0,timescale=0.2;
			var volume;
			var switch=0,snd,snd1,snd2,pos,pos1,pos2,posStart,posEnd,index;
			var frames=BufFrames.kr(buf);
			var duration=BufDur.kr(buf);
			var lfoStart=SinOsc.kr(timescale/Rand(30,60),Rand(hi:2*pi)).range(1024,frames-10240);
			var lfoWindow=SinOsc.kr(timescale/Rand(60,120),Rand(hi:2*pi)).range(4096,frames/2);
			var lfoRate=baseRate;//*Select.kr(SinOsc.kr(1/Rand(10,30)).range(0,4.9),[1,0.25,0.5,1,2]);
			var lfoForward=Demand.kr(Impulse.kr(timescale/Rand(5,15)),0,Drand([0,1],inf));
			var lfoAmp=SinOsc.kr(timescale/Rand(10,30),Rand(hi:2*pi)).range(0.05,0.5);
			var lfoPan=SinOsc.kr(timescale/Rand(10,30),Rand(hi:2*pi)).range(-1,1);
			var rate=Lag.kr(lfoRate*(2*lfoForward-1),1)*BufRateScale.kr(buf);

			// modulate the start/stop
			posStart = lfoStart;
			posEnd = Clip.kr(posStart + lfoWindow,0,frames-1024);

			switch=ToggleFF.kr(LocalIn.kr(1));
			pos1=Phasor.ar(trig:1-switch,rate:rate,end:frames,resetPos:((lfoForward>0)*posStart)+((lfoForward<1)*posEnd));
			pos2=Phasor.ar(trig:switch,  rate:rate,end:frames,resetPos:((lfoForward>0)*posStart)+((lfoForward<1)*posEnd));
			snd1=BufRd.ar(2,buf,pos1,1.0,4);
			snd2=BufRd.ar(2,buf,pos2,1.0,4);
			pos=Select.ar(switch,[pos1,pos2]);
			[pos,posStart,posEnd];
			LocalOut.kr(
				Changed.kr(Stepper.kr(Impulse.kr(50),max:1000000000,
					step:(pos>posEnd)+(pos<posStart)
				))
			);
			snd=SelectX.ar(Lag.kr(switch,0.05),[snd1,snd2]);
			volume = amp*lfoAmp*EnvGen.ar(Env.new([0,1],[Rand(1,10)],4));
			SendReply.kr(Impulse.kr(25),"/position",[tape,player,posStart/frames,posEnd/frames,pos/frames,volume,(lfoPan+1)/2]);

			snd=Balance2.ar(snd[0],snd[1],lfoPan);
			Out.ar(0,snd*volume);
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

		"done loading.".postln;
	}

	play {
		arg tape=1,player=1,rate=1.0,db=0.0,timescale=1;
		var amp=db.dbamp;
		var tapeid="tape"++tape;
		var playid="player"++player;
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

	load {
		arg tape=1,filename="";
		var tapeid="tape"++tape;
		if (filename=="",{
			("[ube] error: need to provide filename").postln;
			^nil
		});
		bufs.put(tapeid,Buffer.read(server,filename,action:{ arg buf;
			("[ube] loaded"+tape+filename).postln;
		}));
	}

	record {
		arg tape=1,seconds=30,recLevel=1.0,preLevel=1.0;
		var tapeid="tape"++tape;
		if (bufs.at(tapeid).isNil,{
			bufs.put(tapeid,Buffer.alloc(server,server.sampleRate*seconds,2));
			server.sync;
		});
		("[ube] record"+tape+seconds+recLevel+preLevel).postln;
		// TODO: silence all output to prevent feedback?

		// initiate recorder
		syns.put("record"++tape,Synth.head(server,"recorder",[\buf,bufs.at(tapeid),\recLevel,recLevel,\preLevel,preLevel]).onFree({
			("[ube] record"+tape+"finished.").postln;
			// TODO: load it as a tape
		}));
		NodeWatcher.register(syns.at("record"++tape));

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
							"close?".postln;
							a.close;
						});
						a = SoundFileView.new(w, Rect(padding,padding, x, h));
						bufs.at(tapeid).loadToFloatArray(0, -1, {|floatArray|
							AppClock.sched(1,{
								a.setData(floatArray*1.5,4096,0,1,bufs.at(tapeid).sampleRate);
								a.gridOn = false;
								a.timeCursorOn = false;
								a.drawsCenterLine  = false;
								a.drawsBoundingLines = false;
								a.peakColor=Color.new255(99,89,133,150);
								a.rmsColor=Color.new255(99,89,133,60);
								a.background_(Color.new255(236,242,255,0));
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
						// a.soundfile=snds.at(tapeid);
						// a.read(0,snds.at(tapeid).numFrames);
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
						var volume01=volume.ampdb.linlin(-64,12,0,1)+0.05;
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

		Routine {
			inf.do({
				0.04.wait;
				if (w.notNil,{
					if (w.isClosed.not,{
						AppClock.sched(0,{w.refresh});
					});
				});
			});
		}.play;
		// while(true,{
		// 	if (w.notNil,{
		// 		if (w.isClosed.not,{
		// 			w.refresh;
		// 		});
		// 	});
		// 	0.04.wait;
		// }).fork(AppClock);


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

