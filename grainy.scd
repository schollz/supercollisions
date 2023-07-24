s.boot;

(
var winenv;

b=Buffer.readChannel(s,"/home/zns/Documents/supercollisions/vocals_bpm100.flac",0,-1,0);
// a custom envelope
winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
z = Buffer.sendCollection(s, winenv.discretize, 1);

SynthDef(\buf_grain_test, { |out, gate = 1, amp = 1, sndbuf, envbuf|
	var pos, env, freqdev,snd;
	var imp=Impulse.kr(60/120*MouseY.kr(1,48));
	// use mouse x to control panning
	pos = Line.kr(0,1,BufDur.ir(sndbuf)*4);
	env = EnvGen.kr(
		Env([0, 1, 0], [1, 1], \sin, 1),
		gate,
		levelScale: amp,
		doneAction: Done.freeSelf);
	snd= GrainBuf.ar(2,imp, MouseX.kr(0.1,10)*TRand.kr(1,10,imp)*(1/MouseY.kr(1,48)), sndbuf, 1, (0.2/BufDur.ir(sndbuf)*TRand.kr(-1,1,imp)+pos).poll, 2);
	snd = snd / 10;
	snd = LPF.ar(snd,4000);

	Out.ar(out,snd		 * env)
}).add;
)
x = Synth(\buf_grain_test, [\sndbuf, b, \envbuf, -1])





(  //
{
	var imp = Dust.ar([0.8,1.1]);
	var input = PlayBuf.ar(2,b,loop:1);

	var pit = LFNoise1.kr(0.3,12);
	var pos = LFNoise2.kr(0.4,0.5,0.5);
	var size = LFNoise1.kr(0.3,0.5,0.5);
	var dens = LFNoise1.kr(0.3,0.5,0.5);
	var tex = LFNoise1.kr(0.3,0.5,0.5);

	var frez = LFClipNoise.kr(0.3);

	MiClouds.ar(input, 0, pos, size, 0.7, tex, drywet: 1, in_gain: 1, rvb:0.3, fb: 0.5,
		freeze: 0, lofi: 0, mode: 0);

}.play
)





(
var winenv;
// a custom envelope
winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
z = Buffer.sendCollection(s, winenv.discretize, 1);

SynthDef(\sin_grain_test, { |out, gate = 1, amp = 1, envbuf|
    var pan, env, freqdev;
    // use mouse x to control panning
    pan = MouseX.kr(-1, 1);
    // use WhiteNoise and mouse y to control deviation from center pitch
    freqdev = WhiteNoise.kr(MouseY.kr(0, 400));
    env = EnvGen.kr(
        Env([0, 1, 0], [1, 1], \sin, 1),
        gate,
        levelScale: amp,
        doneAction: Done.freeSelf
    );
    Out.ar(out,
        GrainSin.ar(2, Impulse.kr(10), 0.1, 440 + freqdev, pan, envbuf) * env)
}).add;
)

s.scope
// use built-in env
x = Synth(\sin_grain_test, [\envbuf, -1])

// switch to the custom env
x.set(\envbuf, z)
x.set(\envbuf, -1);

x.set(\gate, 0);







(
var winenv;
// a custom envelope
winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
z = Buffer.sendCollection(s, winenv.discretize, 1);

SynthDef(\fm_grain_test, { |out, gate = 1, amp = 1, envbuf|
    var pan, env, freqdev;
    // use mouse x to control panning
    pan = MouseX.kr(-1, 1);
    // use WhiteNoise and mouse y to control deviation from center pitch
    freqdev = WhiteNoise.kr(MouseY.kr(0, 400));
    env = EnvGen.kr(
        Env([0, 1, 0], [1, 1], \sin, 1),
        gate,
        levelScale: amp,
        doneAction: Done.freeSelf);
    Out.ar(out,
        GrainFM.ar(2, Impulse.kr(10), 0.1, 440 + freqdev, 200, LFNoise1.kr.range(1, 10),
            pan, envbuf) * env)
}).add;

)

// use built-in env
x = Synth(\fm_grain_test, [\envbuf, -1])

// switch to the custom env
x.set(\envbuf, z)
x.set(\envbuf, -1);
