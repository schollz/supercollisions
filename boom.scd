(
Routine {
	2.do({arg i;
		var ch=i+1;
		SynthDef("drum"++(ch),{
			arg buf,duration=2,rate_start=1,rate_end=1,db_start=0,db_end=0,retrigs=0,gate=1;
			var snd,snd1,snd2,trig,switch,rate,amp,env;
			trig=Impulse.kr(retrigs/duration)+Impulse.kr(0);
			switch=ToggleFF.kr(trig);
			rate=Line.kr(rate_start,rate_end,duration);
			amp=Line.kr(db_start,db_end,duration).dbamp;
			snd1=PlayBuf.ar(ch,buf,rate,switch);
			snd2=PlayBuf.ar(ch,buf,rate,1-switch);
			snd=SelectX.ar(Lag.kr(switch),[snd2,snd1]);
			if (ch==1,{
				snd=Pan2.ar(snd);
			});
			snd=LPF.ar(snd,MouseX.kr(20,20000,1));
			env=EnvGen.ar(Env.new([1,1,0],[duration-0.1,0.1],\sine),doneAction:2);
			// env=env*EnvGen.ar(Env.new([1,0],[0.1],\sine),gate,doneAction:2);
			Out.ar(0,snd*env*amp);
		}).send(s);
	});
	Server.default.sync;
	Routine{
		var a=Buffer.read(Server.default, thisProcess.nowExecutingPath.dirname++"/pulsar-23 postsolarpunk pack/Kick Layered/kick layer 12 [2022-07-05 013433].wav");
		Server.default.sync;
		inf.do({
			x=Synth("drum"++a.numChannels,[\buf,a,\duration,0.5]);
			NodeWatcher.register(x);
			0.5.wait;
			if (6.rand<1,{
				x=Synth("drum"++a.numChannels,[\buf,a,\db_start,-1,\retrigs,6,\rate_end,1,\duration,2]);
				NodeWatcher.register(x);
				2.wait;
			});
			if (6.rand<1,{
				x=Synth("drum"++a.numChannels,[\buf,a,\db_start,0,\db_end,-12,\retrigs,4,\rate_end,-1,\duration,2.5]);
				NodeWatcher.register(x);
				2.5.wait;
			});
		});
	}.play;
	Routine{
		var a=Buffer.read(Server.default, thisProcess.nowExecutingPath.dirname++"/pulsar-23 postsolarpunk pack/Snare 1/Slice 12 [2021-04-17 220546].wav");
		Server.default.sync;
		inf.do({
			x=Synth("drum"++a.numChannels,[\buf,a,\duration,0.25]);
			NodeWatcher.register(x);
			0.25.wait;
			// if (6.rand<1,{
			// 	x=Synth("drum"++a.numChannels,[\buf,a,\db_start,-12,\retrigs,12,\rate_end,1,\duration,2]);
			// 	NodeWatcher.register(x);
			// 	2.wait;
			// });
			// if (6.rand<1,{
			// 	x=Synth("drum"++a.numChannels,[\buf,a,\db_start,0,\db_end,-12,\retrigs,16,\rate_end,0.7,\duration,2.5]);
			// 	NodeWatcher.register(x);
			// 	2.5.wait;
			// });
		});
	}.play;
}.play;
)

Synth("drum"++a.numChannels,[\buf,a,\db_start,-8,\retrig_rate,16,\gate,1,\rate_end,2,\duration,1])