(
s.waitForBoot({
	SynthDef("ssample",{
		arg amp,buf,rate,out,duration=100;

		var snd=PlayBuf.ar(2,buf,rate,doneAction:2);
		var env=EnvGen.ar(Env.new([0,1,1,0],[0.005,duration,0.1]),doneAction:2);
		Out.ar(out,snd*amp*env);
	}).send(s);
	s.sync;
	~hits=Array.fill(3,{ arg i;
		Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/timpani/hits/"++i++".wav");
	});
	~roll=Array.fill(2,{ arg i;
		Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/timpani/roll/"++i++".wav");
	});
	s.sync;
	// hit
	h={
		arg note,velocity,rollTime;
		var eroot=[0.79370052598265, 0.84089641525195, 0.8908987181383, 0.9438743126793 ,1.0, 1.0594630943591, 1.1224620483089, 1.1892071150019, 1.2599210498937, 1.3348398541685, 1.4142135623711, 1.4983070768743, 1.5874010519653, 1.6817928305039, 1.7817974362766, 1.8877486253586];
		var rate=eroot[note.mod(12)];
		var dynamics=[1-velocity,0,velocity];
		var rollDynamics=[1-velocity,velocity];
		if (velocity<0.5,{
			dynamics[1]=velocity*2;
		},{
			dynamics[1]=(1-velocity)*2;
		});
		dynamics.postln;
		Routine{
			if (rollTime>0,{
				rollDynamics.do({ arg v,i;
					[i,v].postln;
					Synth.new("ssample",[\amp,v,\rate,rate,\buf,~roll.at(i),\duration,rollTime]);
				});
			});
			rollTime.wait;
			dynamics.do({ arg v,i;
				[i,v].postln;
				Synth.new("ssample",[\amp,v,\rate,rate,\buf,~hits.at(i)]);
			});

		}.play;
		nil
	};
});
)

h.value(40,0.1,2)
h.value(47,0.1,0.5)

([1.0, 1.0594630943591, 1.1224620483089, 1.1892071150019, 1.2599210498937, 1.3348398541685, 1.4142135623711, 1.4983070768743, 1.5874010519653, 1.6817928305039, 1.7817974362766, 1.8877486253586]/2).postln;


~a=[1,2,3]
~a[1]=4

{ [Line.ar(-1,1,1)*Line.ar(-1,1,1)] }.plot