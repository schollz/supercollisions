// from https://sccode.org/1-5d8

(
SynthDef("kick", {
	arg outBus=0, decay=1, space=1;
	var env0, env1, env1m, out;

	env0 =  EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.06, 0.26*decay], [-4, -2, -4]), doneAction:2);
	env1 = EnvGen.ar(Env.new([110, 59, 29], [0.005, 0.29], [-4, -5]));
	env1m = env1.midicps;

	out = LFPulse.ar(env1m, 0, 0.5, 1, -0.5);
	out = out + WhiteNoise.ar(1*space);
	out = LPF.ar(out, env1m*1.5, env0);
	out = out + SinOsc.ar(env1m, 0.5, env0);

	out = out * 1.2;
	out = out.clip2(1);
	Out.ar(outBus, out.dup);
}).add;


SynthDef("snare", {
	arg outBus=0, amp=0.8;
	var env0, env1, env2, env1m, oscs, noise, out;

	env0 = EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.03, 0.10], [-4, -2, -4]));
	env1 = EnvGen.ar(Env.new([110, 60, 49], [0.005, 0.1], [-4, -5]));
	env1m = env1.midicps;
	env2 = EnvGen.ar(Env.new([1, 0.4, 0], [0.05, 0.13], [-2, -2]), doneAction:2);

	oscs = LFPulse.ar(env1m, 0, 0.5, 1, -0.5) + LFPulse.ar(env1m * 1.6, 0, 0.5, 0.5, -0.25);
	oscs = LPF.ar(oscs, env1m*1.2, env0);
	oscs = oscs + SinOsc.ar(env1m, 0.8, env0);

	noise = WhiteNoise.ar(0.2);
	noise = HPF.ar(noise, 200, 2);
	noise = BPF.ar(noise, 6900, 0.6, 3) + noise;
	noise = noise * env2;

	out = oscs + noise;
	out = out.clip2(1) * amp;

	Out.ar(outBus, out.dup);
}).add;

SynthDef("clap", {
	arg outBus=0, amp = 0.5;
	var env1, env2, out, noise1, noise2;

	env1 = EnvGen.ar(Env.new([0, 1, 0, 1, 0, 1, 0, 1, 0], [0.001, 0.013, 0.001, 0.013, 0.001, 0.013, 0, 0.01, 0, 0.01, 0, 0.03], [0, -3, 0, -3, 0, -3, 0, -4]));
	env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, 0.3], [0, -4]), doneAction:2);

	noise1 = WhiteNoise.ar(env1);
	noise1 = HPF.ar(noise1, 600);
	noise1 = BPF.ar(noise1, 2000, 3);

	noise2 = WhiteNoise.ar(env2);
	noise2 = HPF.ar(noise2, 1000);
	noise2 = BPF.ar(noise2, 1200, 0.7, 0.7);

	out = noise1 + noise2;
	out = out * 2;
	out = out.softclip * amp;

	Out.ar(outBus, out.dup);
}).add;


SynthDef("hat", {
	arg outBus=0, amp=0.3;
	var env1, env2, out, oscs1, noise, n, n2;

	n = 5;
	thisThread.randSeed = 4;

	env1 = EnvGen.ar(Env.new([0, 1.0, 0], [0.001, 0.2], [0, -12]));
	env2 = EnvGen.ar(Env.new([0, 1.0, 0.05, 0], [0.002, 0.05, 0.03], [0, -4, -4]), doneAction:2);

	oscs1 = Mix.fill(n, {|i|
		SinOsc.ar(
			( i.linlin(0, n-1, 42, 74) + rand2(4.0) ).midicps,
			SinOsc.ar( (i.linlin(0, n-1, 78, 80) + rand2(4.0) ).midicps, 0.0, 12),
			1/n
		)
	});

	oscs1 = BHiPass.ar(oscs1, 1000, 2, env1);
	n2 = 8;
	noise = WhiteNoise.ar;
	noise = Mix.fill(n2, {|i|
		var freq;
		freq = (i.linlin(0, n-1, 40, 50) + rand2(4.0) ).midicps.reciprocal;
		CombN.ar(noise, 0.04, freq, 0.1)
	}) * (1/n) + noise;
	noise = BPF.ar(noise, 6000, 0.9, 0.5, noise);
	noise = BLowShelf.ar(noise, 3000, 0.5, -6);
	noise = BHiPass.ar(noise, 1000, 1.5, env2);

	out = noise + oscs1;
	out = out.softclip;
	out = out * amp;

	Out.ar(outBus, out.dup);
}).add;


SynthDef("acid", {
	arg outBus=0, gate=1, pitch=50, amp=8;
	var env1, env2, out;
	pitch = Lag.kr(pitch, 0.12 * (1-Trig.kr(gate, 0.001)) * gate);
	env1 = EnvGen.ar(Env.new([0, 1.0, 0, 0], [0.001, 2.0, 0.04], [0, -4, -4], 2), gate, amp);
	env2 = EnvGen.ar(Env.adsr(0.001, 0.8, 0, 0.8, 70, -4), gate);
	out = LFSaw.ar(pitch.midicps, 2, -1);

	out = MoogLadder.ar(out, (pitch + env2/2).midicps+(LFNoise1.kr(0.2,1100,1500)),LFNoise1.kr(0.4,0.9).abs+0.3,3);
	out = LeakDC.ar((out * env1).tanh/2.7);

	Out.ar(outBus, out.dup);
}).add;


SynthDef("acid2", {
	arg outBus=0, gate=1, pitch=20, amp=3.5;
	var env1, env2, out;
	pitch = Lag.kr(pitch, 0.12 * (1-Trig.kr(gate, 0.001)) * gate);
	env1 = EnvGen.ar(Env.perc(0.001,0.7,4,-4), gate, amp);
	env2 = EnvGen.ar(Env.perc(0.001,0.3,600,-3), gate);
	out = LFPulse.ar(pitch.midicps, 0, 0.5);

	out = RLPFD.ar(out, 100+pitch.midicps + env2,MouseX.kr(0.05,0.3));
	out = LeakDC.ar((out * env1).tanh);

	Out.ar(outBus, out.dup);
}).add;


SynthDef("acid3", {
	arg outBus=0, t_trig=1, pitch=30, amp=3.5,port=0,decay=8,res=0.1,saw=1;
	var env1, env2, out;
	pitch = Lag.kr([pitch,pitch+0.02], port);
	env1 = EnvGen.ar(Env.perc(0.001,decay,4,-4), t_trig, amp);
	env2 = EnvGen.ar(Env.perc(0.001,decay/2,600,-3), t_trig);
	out = SelectX.ar(saw,[Pulse.ar(pitch.midicps),Saw.ar(pitch.midicps)]);
	out = MoogLadder.ar(out, (pitch.midicps + env2)*SinOsc.kr(1/7).range(0.5,1.1),res);
	out = LeakDC.ar((out * env1).tanh);
	Out.ar(outBus, out);
}).add;

)

x=Synth("acid3",[\pitch,30]);
x.set(\t_trig,1,\port,0,\pitch,30,\decay,1);
x.set(\t_trig,1,\port,0.4,\pitch,40,\decay,4,\res,0.9,\saw,1);


Synth("kick",[\decay,16,\space,8])
Synth("kick",[\decay,1,\space,1])

