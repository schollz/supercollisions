FoldersOfSound {

	var server;
	var bufs;
	var buses;
	var syns;
	var synlist;

	*new {
		arg argServer;
		^super.new.init(argServer);
	}

	init {
		arg argServer;

		server=argServer;

		// initialize variables
		syns = Dictionary.new();
		buses = Dictionary.new();
		bufs = Dictionary.new();
		synlist = Array.new();


		// basic players
		SynthDef("fx",{
			arg busReverb,busCompress,busNoCompress;
			var sndReverb=In.ar(busReverb,2);
			var sndCompress=In.ar(busCompress,2);
			var sndNoCompress=In.ar(busNoCompress,2);
			sndCompress=Compander.ar(sndCompress,sndCompress,0.05,slopeAbove:0.1,relaxTime:0.01);
			sndNoCompress=Compander.ar(sndNoCompress,sndNoCompress,1,slopeAbove:0.1,relaxTime:0.01);
			// sndReverb=Fverb.ar(sndReverb[0],sndReverb[1],60,decay:80);
			sndReverb=FreeVerb2.ar(sndReverb[0],sndReverb[1],1.0,0.7);
			Out.ar(0,sndCompress+sndNoCompress+sndReverb);
		}).send(server);

		SynthDef("looper1",{
			arg buf,busReverb,busCompress,busNoCompress,gate=1,timescale=20;
			var sndl,sndr;
			var snd=XPlayBuf.ar(1,buf,loop:1,trigger:Impulse.kr(0),startPos:BufDur.ir(buf)*Rand(0,1),fadeTime:3);
			var lr=VarLag.kr(LFNoise0.kr(1/timescale),timescale,warp:\sine);
			var fb=VarLag.kr(LFNoise0.kr(1/timescale),timescale,warp:\sine);
			var pan=lr*0.5;
			var amp=VarLag.kr(LFNoise0.kr(1/timescale),timescale,warp:\sine).range(0,1)*(Rand(-12,0).dbamp);
			snd=HPF.ar(snd,LinLin.kr(fb,-1,1,20,1000));
			sndl=snd;
			sndr=snd;
			sndl=LPF.ar(sndl,LinLin.kr(lr,-1,1,135,100).midicps);
			sndr=LPF.ar(sndr,LinLin.kr(lr,-1,1,100,135).midicps);
			sndl=SelectX.ar(((lr>0.1)*lr.abs),[sndl,DelayN.ar(sndl,0.03,Rand(0.0,0.03))]);
			sndr=SelectX.ar(((lr<0.1.neg)*lr.abs),[sndr,DelayN.ar(sndr,0.03,Rand(0.0,0.03))]);
			snd=Balance2.ar(sndl,sndr,pan,amp)*Line.kr(0,1,1);
			snd=snd*EnvGen.ar(Env.adsr(10,1,1,10,curve:[4,4]),gate,doneAction:2);
			Out.ar(busCompress,(fb+1)/2*snd);
			Out.ar(busNoCompress,(1-((fb+1)/2))*snd);
			Out.ar(busReverb,LinExp.kr(fb,1,-1,0.01,0.19)*snd);
		}).send(server);

		SynthDef("looper2",{
			arg buf,busReverb,busCompress,busNoCompress,gate=1,timescale=20;
			var sndl,sndr;
			var snd=XPlayBuf.ar(2,buf,loop:1,trigger:Impulse.kr(0),startPos:BufDur.ir(buf)*Rand(0,1),fadeTime:3);
			var lr=VarLag.kr(LFNoise0.kr(1/timescale),timescale,warp:\sine);
			var fb=VarLag.kr(LFNoise0.kr(1/timescale),timescale,warp:\sine);
			var pan=lr*0.5;
			var amp=VarLag.kr(LFNoise0.kr(1/timescale),timescale,warp:\sine).range(0,1)*(Rand(-12,0).dbamp);
			snd=HPF.ar(snd,LinLin.kr(fb,-1,1,20,1000));
			sndl=snd[0];
			sndr=snd[1];
			sndl=LPF.ar(sndl,LinLin.kr(lr,-1,1,135,100).midicps);
			sndr=LPF.ar(sndr,LinLin.kr(lr,-1,1,100,135).midicps);
			sndl=SelectX.ar(((lr>0.1)*lr.abs),[sndl,DelayN.ar(sndl,0.03,Rand(0.0,0.03))]);
			sndr=SelectX.ar(((lr<0.1.neg)*lr.abs),[sndr,DelayN.ar(sndr,0.03,Rand(0.0,0.03))]);
			snd=Balance2.ar(sndl,sndr,pan,amp)*Line.kr(0,1,1);
			snd=snd*EnvGen.ar(Env.adsr(10,1,1,10,curve:[4,4]),gate,doneAction:2);
			Out.ar(busCompress,(fb+1)/2*snd);
			Out.ar(busNoCompress,(1-((fb+1)/2))*snd);
			Out.ar(busReverb,LinExp.kr(fb,1,-1,0.01,0.19)*snd);
		}).send(server);

		server.sync;

		// define buses
		buses.put("busCompress",Bus.audio(server,2));
		buses.put("busNoCompress",Bus.audio(server,2));
		buses.put("busReverb",Bus.audio(server,2));
		server.sync;

		// define fx
		syns.put("fx",Synth.tail(server,"fx",[\busReverb,buses.at("busReverb"),\busNoCompress,buses.at("busNoCompress"),\busCompress,buses.at("busCompress")]));
		server.sync;
		"done loading.".postln;
	}

	playFolder {
		arg folder, num;
		var files = PathName.new(folder);
		var audioFiles = [];
		files.filesDo({arg file;
			if (file.fullPath.endsWith(".ogg"),{
				audioFiles=audioFiles.add(file.fullPath);
			});
			if (file.fullPath.endsWith(".wav"),{
				audioFiles=audioFiles.add(file.fullPath);
			});
			if (file.fullPath.endsWith(".flac"),{
				audioFiles=audioFiles.add(file.fullPath);
			});
		});
		("loaded"+audioFiles.size+"files from"+folder).postln;
		audioFiles.scramble.do({ arg v,i;
			if (i<num,{
				[i,v].postln;
				this.play(v);
			});
		})
	}

	remove {
		arg num;
		num.do({ arg i;
			if (synlist.size>0,{
				this.stop(synlist[0]);
			});
		});
	}

	stop {
		arg fname;
		if (syns.at(fname).notNil,{
			var remove=1.neg;
			if (syns.at(fname).isRunning,{
				("stopping"+fname).postln;
				syns.at(fname).set(\gate,0);
			});
			syns.put(fname,nil);
			synlist.do({arg v,i;
				if (v.asString==fname.asString,{
					remove=i;
				});
			});
			if (remove>1.neg,{
				("dequeued"+fname).postln;
				synlist.removeAt(remove);
			});
		});
	}

	play {
		arg fname;
		if (bufs.at(fname).isNil,{
			bufs.put(fname,Buffer.read(server,fname,0,-1,action:{
				syns.put(fname,Synth.before(syns.at("fx"),"looper"++bufs.at(fname).numChannels,[\buf,bufs.at(fname),\busReverb,buses.at("busReverb"),\busNoCompress,buses.at("busNoCompress"),\busCompress,buses.at("busCompress")]));
				NodeWatcher.register(syns.at(fname));
			}));
		},{
			// only allow one sample of one kind to play at once
			this.stop(fname);
			syns.put(fname,Synth.before(syns.at("fx"),"looper"++bufs.at(fname).numChannels,[\buf,bufs.at(fname),\busReverb,buses.at("busReverb"),\busNoCompress,buses.at("busNoCompress"),\busCompress,buses.at("busCompress")]));
			NodeWatcher.register(syns.at(fname));
		});
		synlist=synlist.add(fname);
	}


	free {
		bufs.keysValuesDo({ arg k, val;
			val.free;
		});
		syns.keysValuesDo({ arg k, val;
			val.free;
		});
		buses.keysValuesDo({ arg k, val;
			buses.free;
		});
	}
}
