(
s.waitForBoot({
	SynthDef("piano",{
		arg out=0,hz=400,amp=1.0,pan=0,gate=1,
		sub=0,portamento=1,bend=0,
		attack=0.01,decay=0.2,sustain=0.9,release=5,
		mod1=1,mod2=0,mod3=0.5.neg,mod4=0,duration=600;
		var snd,note,env, damp;
		var noise, string, delaytime, lpf, noise_env, damp_mul;
		var noise_hz = hz+1000, noise_attack=0.002, noise_decay=0.002,
		tune_up = 1.0005, tune_down = 0.9996, string_decay=4.0,
		lpf_ratio=1, lpf_rq = 4, hpf_hz = 40, damp_time=0.5;
		mod1=Lag.kr(mod1);mod2=Lag.kr(mod2);mod3=Lag.kr(mod3);mod4=Lag.kr(mod4);


		hz=(Lag.kr(hz,portamento).cpsmidi + bend).midicps;

		damp = 0;
		damp_mul = LagUD.ar(K2A.ar(1.0 - damp), 0, damp_time);

		noise_env = Decay2.ar(Impulse.ar(0));
		noise = LFNoise2.ar(noise_hz) * noise_env;

		delaytime = 1.0 / (hz * [tune_up, tune_down]);
		string = Mix.new(CombL.ar(noise, delaytime, delaytime, string_decay * damp_mul));
		string = LPF.ar(string,noise_hz/2);
		snd = RLPF.ar(string, lpf_ratio * hz, lpf_rq);
		snd = HPF.ar(snd, hpf_hz);
		snd = Pan2.ar(snd,Lag.kr(pan,0.1));

		// snd = SelectX.ar(LFNoise2.kr(1).range(0,1),[snd,SinOsc.ar(hz * [tune_up, tune_down],mul:EnvGen.ar(Env.perc(noise_attack,string_decay)))]);

		DetectSilence.ar(snd,doneAction:2);
		Out.ar(out,snd*amp/5);
	}).play;
});
)