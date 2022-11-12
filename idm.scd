// bit of an afternoon playing random noises turned out to sound relatively IDM-ish

// I stole the kick & snare from the dubstep thing off the list a while ago... thanks

(
SynthDef("idm",{
	arg out=0, freq=330, gate=1;
	var sound,  ampenv, filterenv, mod, snare, snaretrig, kick, kickenv, lin;
	var trigtime=TWChoose.kr(Impulse.kr(0),[1,2,4,8,16],[1,1,1,1,1],1);
	var time=TWChoose.kr(Impulse.kr(0),[1/8,1/4,1],[2,1,0.2],1);
	mod = LFNoise2.kr({0.01.rand}.dup(2), [0.01.rand,0.001.rand,0.5.rand].choose, 1.0);


	filterenv = EnvGen.kr(Env.adsr(),gate);

	ampenv = filterenv;//EnvGen.kr(Env.perc(0.01,time/2.0.rand.max(1/8),1.0.rand),doneAction:2);

	sound = Select.ar(5.rand, [
		Pulse.ar(freq.poll*mod,0.5).tanh,
		LFTri.ar(freq*mod,0).tanh,
		Pulse.ar(freq*mod,0.5).tanh,
		LFSaw.ar(freq*mod,0.5).tanh,
		SinOscFB.ar(freq*mod,100.0.rand).tanh
	]);

	sound = RLPF.ar(sound, filterenv, LFNoise2.kr(0.01.rand, 0.3, 0.5) );
	sound = sound * ampenv;

	sound = sound + (DelayC.ar(sound, 1/4, {[1/4,1/8].choose}.dup(2)) * [1.0.rand,0]);

	5.do{sound = (sound.clip + sound)*0.75};

	sound = LPF.ar(sound, LFNoise2.kr(trigtime, 250, 500) );

	// snaretrig = Impulse.kr(trigtime);
	// snare = 3*PinkNoise.ar(1!2) *
	// EnvGen.kr(Env.perc(0.01,0.01,[0,0.3.rand].choose),snaretrig);
	// 5.do{snare = AllpassC.ar(snare, 0.5, {0.05.rand}.dup(2), 1.0.rand)+snare};
	// 5.do{snare = (snare.distort + snare)*0.85};
	//
	// kickenv = EnvGen.kr(Env.perc(0.01,time,[0,1.0.rand].choose));
	// kick = SinOsc.ar(40!2+(kickenv**3*200),0,7*kickenv) * kickenv;
	// 5.do{kick = (kick.distort + kick)*0.75};
	//
	// sound = Limiter.ar(sound + snare + kick, 1.0, 0.00001);

	Out.ar(0,sound.tanh);
}).add;
)



Pbind(\instrument, \idm, \freq, Pseq(([60,62,65,60,62,65,60,62,65,60,62,65,58,62,67,58,62,67,58,62,67,58,62,67]+12).midicps, inf), \dur, Pseq([60/180/2],inf)).play;
