LinExp.kr(0.5,0.01,0.5,0.01,0.29)
mod1=MouseY.kr(0,1);
mod2=MouseX.kr(0,1);
LinExp.kr(mod1,0,1,0.3,3)


(
SynthDef("snare", {
	arg outBus=0, amp=1.0, mod1=0.5, mod2=0.5, pitch=40,
	reverbOut, reverbSend=0, delayOut, delaySend=0;
	var env0, env1, env2, env1m, oscs, noise, out, snd;

	env0 = EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.03, 0.10]*LinExp.kr(mod1,0,1,1/2,2), [-4, -2, -4]));
	env1 = EnvGen.ar(Env.new([110, 60, 49], [0.005, 0.1]*LinExp.kr(mod1,0,1,1/2,2), [-4, -5]));
	env1m = env1.midicps;
	env2 = EnvGen.ar(Env.new([1, 0.4, 0], [0.05, 0.13]*LinExp.kr(mod1,0,1,1/2,2), [-2, -2]), doneAction:2);

	oscs = LFPulse.ar(env1m, 0, 0.5, 1, -0.5) + LFPulse.ar(env1m * 1.6, 0, 0.5, 0.5, -0.25);
	oscs = LPF.ar(oscs, env1m*1.2, env0);
	oscs = oscs + SinOsc.ar(env1m, 0.8, env0);

	noise = WhiteNoise.ar(0.2*LinExp.kr(mod2,0,1,1/20,2));
	noise = HPF.ar(noise, 200, 2);
	noise = BPF.ar(noise, 6900, 0.6, 3) + noise;
	noise = noise * env2;

	out = oscs + noise;
	out = out.clip2(1) * amp * 0.3;
	snd = out.dup;

	Out.ar(delayOut,snd*delaySend);
	Out.ar(reverbOut,snd*reverbSend);
	Out.ar(outBus, snd);
}).play;
)