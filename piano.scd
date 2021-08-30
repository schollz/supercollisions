// 1. run this
(
SynthDef("effects",{
		arg busin;
	var snd;
	snd = In.ar(busin,2);
	snd = Greyhole.ar(snd,0.2,0.1,1,0.707,0.05,0.05,2);
	Out.ar(0,snd);
}).add;

SynthDef.new(\comb_piano, {
			arg out=0, amp=1, hz=220,
			noise_hz = 4000, noise_attack=0.002, noise_decay=0.1,
			tune_up = 1.0005, tune_down = 0.9996, string_decay=16.0,
			lpf_ratio=2.0, lpf_rq = 4.0, hpf_hz = 40, damp=0, damp_time=0.1,gate=1;

			var noise, string, delaytime, lpf, noise_env, snd, damp_mul;

			damp_mul = LagUD.ar(K2A.ar(1.0 - damp), 0, damp_time);

			noise_env = Decay2.ar(Impulse.ar(0));
			noise = LFNoise2.ar(noise_hz) * noise_env;

			delaytime = 1.0 / (hz * [tune_up, tune_down]);
			string = Mix.new(CombL.ar(noise, delaytime, delaytime, string_decay * damp_mul));
			snd = RLPF.ar(string, lpf_ratio * hz, lpf_rq) * amp;
			snd = HPF.ar(snd, hpf_hz);
	        snd = snd * EnvGen.ar(Env.adsr(),gate:gate);

			Out.ar(out, 0.2*snd.tanh.dup);
			DetectSilence.ar(snd, doneAction:2);
		}).add;
)


// 2. run this
(
y=Bus.audio(s,2);
x=Synth("effects",[\busin,y]);
)

// 3. attach midi device and then run this
(

var notes, on, off;


MIDIClient.init;
MIDIIn.connectAll;

notes = Array.newClear(128);

on = MIDIFunc.noteOn({ |veloc, num, chan, src|
	[veloc,num,chan,src].postln;
    notes[num] = Synth(\comb_piano, [\hz, num.midicps,
        \amp, veloc * 0.00315*3,\out,y]);
});

off = MIDIFunc.noteOff({ |veloc, num, chan, src|
    notes[num].set(\gate,0);
});

q = { on.free; off.free; };
)

q.value