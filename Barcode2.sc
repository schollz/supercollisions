Barcode2 {

	var server;
	var bufs;
	var syns;

	*new {
		arg argServer;
		^super.new.init(argServer);
	}

	init {
		arg argServer;

		server=argServer;

		// initialize variables
		syns = Dictionary.new();
		bufs = Dictionary.new();

		// basic players
		SynthDef("recorder",{
			arg buf,recLevel=1.0,preLevel=0.0;
			RecordBuf.ar(SoundIn.ar([0,1]),buf,0.0,recLevel,preLevel,loop:0,doneAction:2);
		}).send(server);

		SynthDef("looper",{
			arg buf,tape,player,baseRate=1.0,amp=1.0;
			var volume;
			var switch=0,snd,snd1,snd2,pos,pos1,pos2,posStart,posEnd,index;
			var frames=BufFrames.ir(buf);
			var duration=BufDur.ir(buf);
			var lfoStart=SinOsc.kr(1/Rand(10*duration,20*duration),Rand(hi:2*pi)).range(1024,frames-10240);
			var lfoWindow=SinOsc.kr(1/Rand(60,120),Rand(hi:2*pi)).range(4096,frames/2);
			var lfoRate=baseRate;//*Select.kr(SinOsc.kr(1/Rand(10,30)).range(0,4.9),[1,0.25,0.5,1,2]);
			var lfoForward=Demand.kr(Impulse.kr(1/Rand(5,15)),0,Drand([0,1],inf));
			var lfoAmp=SinOsc.kr(1/Rand(10,30),Rand(hi:2*pi)).range(0.05,0.5);
			var lfoPan=SinOsc.kr(1/Rand(10,30),Rand(hi:2*pi)).range(-1,1);
			var rate=Lag.kr(lfoRate*(2*lfoForward-1),1);

			// modulate the start/stop
			posStart = (lfoStart);
			// posStart=0.1*frames;
			posEnd = Clip.kr(posStart + lfoWindow,0,frames-1024);
			// posEnd=0.2*frames;

			switch=ToggleFF.kr(LocalIn.kr(1));
			pos1=Phasor.ar(1-switch,BufRateScale.ir(buf)*rate,end:frames,resetPos:((lfoForward>0)*posStart)+((lfoForward<1)*posEnd));
			pos2=Phasor.ar(switch,BufRateScale.ir(buf)*rate,end:frames,resetPos:((lfoForward>0)*posStart)+((lfoForward<1)*posEnd));
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
			SendReply.kr(Impulse.kr(10),"/position",[player,posStart/frames,posEnd/frames,pos/frames,volume]);

			snd=Balance2.ar(snd[0],snd[1],lfoPan);
			Out.ar(0,snd*volume);
		}).send(server);

		server.sync;

		"done loading.".postln;
	}

	play {
		arg tape=1,player=1,baseRate=1.0,amp=1.0;
		var tapeid="tape"++tape;
		var playid="player"++player;
		if (bufs.at(tapeid).isNil,{
			("[barcode] cannot play empty tape"+tape).postln;
			^0
		});
		("[barcode] playing tape"+tape+playid).postln;

		syns.put(playid,Synth.head(server,"looper",[\tape,tape,\player,player,\buf,bufs.at(tapeid),\baseRate,baseRate,\amp,amp]).onFree({
			("[barcode] player"+player+"finished.").postln;
		}));
		NodeWatcher.register(syns.at(playid));
	}

	load {
		arg tape=1,filename;
		var tapeid="tape"++tape;
		bufs.put(tapeid,Buffer.read(server,filename,action:{
			("[barcode] loaded"+tape+filename).postln;
		}));
		server.sync;
	}

	record {
		arg tape=1,seconds=30,recLevel=1.0,preLevel=1.0;
		var tapeid="tape"++tape;
		if (bufs.at(tapeid).isNil,{
			bufs.put(tapeid,Buffer.alloc(server,server.sampleRate*seconds,2));
			server.sync;
		});
		("[barcode] record"+tape+seconds+recLevel+preLevel).postln;
		// TODO: silence all output to prevent feedback?

		// initiate recorder
		syns.put("record"++tape,Synth.head(server,"recorder",[\buf,bufs.at(tapeid),\recLevel,recLevel,\preLevel,preLevel]).onFree({
			("[barcode] record"+tape+"finished.").postln;
		}));
		NodeWatcher.register(syns.at("record"++tape));

	}

	free {
		bufs.keysValuesDo({ arg k, val;
			val.free;
		});
		syns.keysValuesDo({ arg k, val;
			val.free;
		});
	}
}
