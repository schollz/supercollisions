(
s.waitForBoot({


	SynthDef("0",{
		arg out,buf,start=0,dur=0.25,xfade=0.05,bpm=160,bpm_source=150;
		var snd,sndD,bass,env=1,retrig=0,startPos=0,trigger=0,phase,rate,jump,do_jump;
		var retrigs=[0,0,0,1,2,4,8,16,32];
		rate=BufRateScale.ir(buf)*bpm/bpm_source;
		retrig=Select.kr(MouseX.kr(0,retrigs.size),retrigs);
		phase=Gate.ar(Phasor.ar(0,rate,0,BufFrames.ir(buf)),retrig<1);
		jump=Demand.kr(Impulse.kr(bpm/120),0,Drand([0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]/16,inf));
		do_jump = Trig.kr((retrig < 1)*Changed.kr(jump)*(MouseY.kr()>LFNoise0.kr(bpm/120).range(0,1)));
		phase=Select.kr(do_jump,[phase,
			jump*BufFrames.ir(buf)
		]);
		[retrig,do_jump].poll;

		snd=PlayBuf.ar(2,
			bufnum:buf,
			rate:Select.kr(MouseY.kr(0,7),[-1,1,1,1,1,1])*rate,
			trigger:Impulse.ar(Lag.kr(bpm/60*retrig))+Trig.kr(retrig<1)+do_jump,
			startPos:phase,
			loop:1,
		);
		//bass=SinOscFB.ar(Demand.kr(Changed.kr(Impulse.kr(bpm/60)),0,Drand([24,25,27,29],inf).midicps),LFNoise2.kr(1/3).range(0,1));
		//snd = snd + (bass*EnvGen.ar(Env.perc(0.1,0.5),Impulse.kr(bpm/60*2)));

		env=env*EnvGen.ar(Env.new([0,-32,0],[0.01,LFNoise0.kr(1).range(0,1)]),retrig>0).dbamp;
		snd=Select.ar(retrig>0,[
			snd,
			RLPF.ar(snd,EnvGen.ar(Env.new([20000,500,20000],[0.01,LFNoise0.kr(1).range(1,5)]),retrig>0),0.25),
		]);

/*		sndD = (snd * 30.dbamp).tanh * -20.dbamp;
		snd = SelectX.ar(MouseY.kr(),[snd,sndD]);*/

		Out.ar(out,snd*env);
	}).send(s);


	Routine {
		s.sync;
		b=Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/amenbreak_bpm136.wav");
		s.sync;

		Synth("0",[
			out:0,
			buf:b,
			bpm:170,
			bpm_source:136,
		]);
	}.play;

});
)


136/60