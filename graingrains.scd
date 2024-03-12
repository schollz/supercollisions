///////////////////////////////
// Granular Sampling Examples
// MUSC 9 - Intro to Electronic Music
// 2014-02-07
////////////////////////////////


// First, make sure you boot the server! (Ctrl + B)

// Remember the other key shortcuts in SuperCollider:
// Ctrl + Enter to evaluate a line or selection or code block
// Ctrl + Period to stop all sounds


// **************************************
// 1) LOAD A SOUND FILE INTO A BUFFER
// **************************************

// Change the file path as needed and evaluate the line below:
b = Buffer.readChannel(s, PathName.new("/home/zns/Music/spliceloop2/strings-orchestral-a/120/").files.scramble[0].asAbsolutePath, channels: [0]);
c = Buffer.readChannel(s, "/home/zns/Music/spliceloop2/leads-synth-am/120/mdh_syn120_issue_Am_keyAmin_bpm120_beats8_.flac", channels: [0]);
c.play;
b.play;

// Listen to the sound file if you want:
{ PlayBuf.ar(1, b) }.play;

// Why not some instant fun, right?
{ PlayBuf.ar(2, b, MouseX.kr(0, 2)) }.play;

// **************************************
// 2) LOAD THE GRANULAR INSTRUMENT
// **************************************

// The code block below is the "instrument".
// You just have to evaluate it once at the beginning.
// Put your cursor anywhere between the top and bottom
// parentheses and hit ctrl + enter to evaluate.
(
SynthDef("granular_sampling", {arg trigger = 0, graindur = 0.2, sndbuf, transp = 1, pos = 0, pan = 0, envbuf = -1, amp = 1, gate = 1;
	var env, snd;
	env = EnvGen.kr(Env.asr, gate, levelScale: amp, doneAction: 2);
	snd = GrainBuf.ar(
		numChannels: 2,
		trigger: Impulse.kr(trigger),
		dur: graindur,
		sndbuf: sndbuf,
		rate: transp,
		pos: pos,
		pan: pan,
		envbufnum: envbuf);
	Out.ar(0, snd * env);
}).add;
)


z = Buffer.sendCollection(s, Env.perc.discretize, 1);
c.play;
(
var bpm = 130;
TempoClock.default.tempo = bpm/60;
Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, Pseq([1,1,1,1,1,1,1.1,0.9]/TempoClock.default.tempo,inf),
	\sndbuf, c,
	\transp, Pseq([1], inf),
	\pos, Pseq([0.3,0.3,0.5,0.3,0.3,0.5,0.3,0.5], inf),
	\pan, Pwhite(-0.25, 0.25),
	\amp, Prand([1,1,0.5,1,1,0.5,1,0.5], inf),
	// \envbuf, -1,
	\envbuf, z,
	\dur, Pseq([1,1,1,1,1,1]/TempoClock.default.tempo, inf);
).play;

Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, Pseq([1,1,1,1,1,1]/TempoClock.default.tempo,inf),
	\sndbuf, b,
	\transp, Pseq([1], inf),
	\pos, Pseq([0.3,0.3,0.5,0.3,0.3,0.5,0.3,0.5]+0.2, inf),
	\pan, Pwhite(-0.25, 0.25),
	\amp, Prand([1,1,0.5,1,1,0.5,1,0.5], inf),
    \envbuf, -1,
	//\envbuf, z,
	\dur, Pseq([1,1,1,1,1,1,1,1]/TempoClock.default.tempo, inf);
).play;
)

// **************************************
// 3) PLAY IT USING PATTERNS (Pbind)
// **************************************

(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, 4,
	\sndbuf, b,
	\transp, 1,
	\pos, 0.6555,
	\pan, 0,
	\amp, 0.9,
	\envbuf, -1,
	\dur, Pseq([0.125, 0.125, 0.125, 0.125, 0.1, 0.1, 0.1], inf);
).play;
)

/*
Explanation of the parameters:
- TRIGGER: how many grains per second. Zero means just one grain. Texture gets denser with higher numbers.
- GRAINDUR: duration of the grain, in seconds.
- SNDBUF: the buffer where the sound file is loaded.
- TRANSP: transposition rate. 1 = no transp, 2 = octave above, 1/2 = octave below, etc. If you use a negative number, it will be played in REVERSE!
- POS: position (0-1) in the sound file from where to read the grain.
- PAN: placement of the resulting grain between Left and Right speakers (-1 to +1).
- AMP: amplitude of the grain (volume), between 0 and 1.
- ENVBUF: the amplitude envelope of a single grain (-1 gives you a default env).
- DUR: this is where you specify the rhythm of the sequence (values in seconds)
*/


// You can do a lot just by changing those fixed numbers.
// But you can do a lot more if you create PATTERNS with them...

(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, Pseq([0.33, 0.34, 0.26, 0.51], inf),
	\sndbuf, b,
	\transp, Pseq([1, 1, 1, 1, 1, 1, 1, 1.5], inf),
	\pos, Pseq([0.2, 0.11, 0.12, 0.14], inf),
	\pan, Pwhite(-1, 1),
	\amp, Prand([0.9, 1], inf),
	\envbuf, -1,
	\dur, Pseq([0.25, 0.125, 0.125, 0.6], inf);
).play;
)

/*

Explanation of pattern expressions:

Pwhite(0, 1) = will pick any number between a low and a high value that you provide (in this case, 0 and 1).

Pseq([1, 2, 5, 3], inf) = will read a list in sequence from left to right. List has to be between [ ].

Prand([1, 2, 5, 3], inf) = will pick a random item FROM THE LIST every time. List has to be between [ ].

You can use a pattern like the above to define any parameter inside the Pbind, as long as you choose sensible values.

*/

// Here's another example:
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, Pwhite(1, 2),
	\graindur, Pseq([0.3, 0.4, 0.6, 1], inf),
	\sndbuf, b,
	\transp, Prand([1, 1, 1, 1, 1], inf),
	\pos, Prand([0, 0.1, 0.2, 0.14, 0.1, 0.1, 0.14], inf),
	\pan, Pseq([-1, -0.5, 0, 0.5, 1], inf),
	\amp, Prand([0.5, 1], inf),
	\envbuf, -1,
	\dur, Pseq([0.15, 0.2], inf);
).play;
)

// The default grain envelope is like a "bell shape", smooth attack and decay.
// Try now applying a custom grain envelope, for example a percussive one.



// Now in the Pbind you can use "z" for envbuf instead of -1.

// Another example
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, Pseq([Pseq([0.1], 15), 0.2], inf),
	\sndbuf, b,
	\transp, Pseq([ Pseq([1], 7), Prand([1, 0.9], 1) ], inf),
	\pos, Pseq([0, 0.1, 0.2, 0.5, 0.1, 0.1, 0.32, 0.2322], inf) * Prand([1, 2], inf),
	\pan, Pwhite(-0.5, 0.5),
	\amp, Pwhite(0.8, 1),
	\envbuf, -1,
	\dur, 0.15;
).play;
)

// Yet another example
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 4,
	\graindur, 0.05,
	\sndbuf, b,
	\transp, -24 + Pwrand([1, 2], [0.9, 0.1], inf),
	\pos, Pxrand([0.8, 0.1, 0.11, 0.12], inf),
	\pan, Pwhite(-0.4, 0.4),
	\amp, 1,
	\envbuf, -1,
	\dur, Pseq([Pseq([1/16], 15), Pseq([1/64, 1/64, 1/32], 1)], inf) * 3,
).play;
)

// One more example
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 5,
	\graindur, Pseq([0.9, 5, 0.9, 5], inf),
	\sndbuf, b,
	\transp, Pseq([0.5, 0.5, 0.5, 0.5], inf),
	\pos, Pseq([0.12, 0.12, 0.12, 0.12], inf),
	\pan, 0,
	\amp, 1.5,
	\envbuf, z,
	\dur, Pseq([1, 1, 1, 1], inf) * 1/2,
).play;
)

// Last example
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 13,
	\graindur, 4,
	\sndbuf, b,
	\transp, Pwhite(0.9, 1.2),
	\pos, Pseq([0.12, 0.12, 0, 0.13, 0.14], inf) + Pwhite(0, 0.01),
	\pan, 0,
	\amp, 1,
	\envbuf, -1,
	\dur, 0.9,
).play;
)



// Last last example: two simultaneous Pbinds
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 1,
	\graindur, 0.05,
	\sndbuf, b,
	\transp, 10,
	\pos, Pxrand([0.8, 0.1, 0.11, 0.12], inf),
	\pan, Pwhite(-0.4, 0.4),
	\amp, 1,
	\envbuf, z,
	\dur, Pseq([Pseq([1/16], 15), Pseq([1/64, 1/64, 1/32], 1)], inf) * 3,
).play;

Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, 0.9,
	\sndbuf, b,
	\transp, Pwrand([1, 0.5], [0.9, 0.1], inf),
	\pos, Pxrand([0.8, 0.1, 0.11, 0.12], inf), // + Pseq((0,0.001..0.1), inf),
	\pan, Pwhite(-0.8, 0.8),
	\amp, 2,
	\envbuf, z,
	\dur, Pseq([Pseq([1/16], 15), Pseq([1/64, 1/64, 1/32], 1)], inf) * 6,
).play;
)



// **************************************
// Favorite Samples
// **************************************

// Laser1
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, 0.8,
	\sndbuf, b,
	\transp, 1,
	\pos, 0.115,
	\pan, 0,
	\amp, 0.9,
	\envbuf, -1,
	\dur, 0.5;
).play;
)

// Laser2
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, 0.8,
	\sndbuf, b,
	\transp, 1,
	\pos, 0.1155,
	\pan, 0,
	\amp, 0.9,
	\envbuf, -1,
	\dur, 0.5;
).play;
)

// Laser2-05
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, 0.8,
	\sndbuf, b,
	\transp, 1.05,
	\pos, 0.1155,
	\pan, 0,
	\amp, 0.9,
	\envbuf, -1,
	\dur, 0.5;
).play;
)

// Laser2-1
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, 0.8,
	\sndbuf, b,
	\transp, 1.1,
	\pos, 0.1155,
	\pan, 0,
	\amp, 0.9,
	\envbuf, -1,
	\dur, 0.5;
).play;
)

// Laser2-2
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, 0.8,
	\sndbuf, b,
	\transp, 1.2,
	\pos, 0.1155,
	\pan, 0,
	\amp, 0.9,
	\envbuf, -1,
	\dur, 0.5;
).play;
)

// Laser3
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, Pseq([1, 2, 1, 2], inf),
	\sndbuf, b,
	\transp, Pseq([1, 1, 1, 1], inf),
	\pos, 0.1155,
	\pan, 0,
	\amp, 0.9,
	\envbuf, -1,
	\dur, 0.5;
).play;
)

// rumble
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 5,
	\graindur, 1,
	\sndbuf, b,
	\transp, 0.02,
	\pos, 0.084,
	\pan, 0,
	\amp, 4,
	\envbuf, -1,
	\dur, 0.5;
).play;
)

// buzz1
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 3,
	\graindur, Pseq([0.9, 5, 0.9, 5], inf),
	\sndbuf, b,
	\transp, Pseq([0.5, 0.5, 0.5, 0.5], inf),
	\pos, Pseq([0.12, 0.12, 0.12, 0.12], inf),
	\pan, 0,
	\amp, 1.5,
	\envbuf, z,
	\dur, Pseq([1, 1, 1, 1], inf) * 1/2,
).play;
)

// buzz2
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 5,
	\graindur, Pseq([0.9, 5, 0.9, 5], inf),
	\sndbuf, b,
	\transp, Pseq([0.5, 0.5, 0.5, 0.5], inf),
	\pos, Pseq([0.12, 0.12, 0.12, 0.12], inf),
	\pan, 0,
	\amp, 1.5,
	\envbuf, z,
	\dur, Pseq([1, 1, 1, 1], inf) * 1/2,
).play;
)

// buzz3
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 5,
	\graindur, Pseq([0.9, 5, 0.9, 5], inf),
	\sndbuf, b,
	\transp, Pseq([0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.2, 4, 15, 14, 13, 12, 11, 10, 5, 1], inf),
	\pos, Pseq([0.12, 0.12, 0.12, 0.12], inf),
	\pan, Pseq([0,0,0,0,0,0,0,0,1,0.8,0.6,0.3,0,-0.3,-0.6,-0.9]),
	\amp, 1.5,
	\envbuf, z,
	\dur, Pseq([1, 1, 1, 1, 1,1,1,1,0.5,0.5,0.15,0.15,0.15,0.15,0.15,0.15], inf) * 1/2,
).play;
)

// kick
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, 0.15,
	\sndbuf, b,
	\transp, 1,
	\pos, 0.6265,
	\pan, 0,
	\amp, 0.9,
	\envbuf, 1,
	\dur, 0.5;
).play;
)

//
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, Pseq([0.25,0.5,0.25,0.5,0.5,0.1,0.1,0.1,0.05,0.25,0.1,0.25,0.5,0.75], inf),
	\sndbuf, b,
	\transp, Pseq([1,-1,1,1,1,1,-1], inf),
	//\pos, Pseq([0], inf),
	\pan, Pwhite(-0.25, 0.25),
	\amp, Prand([1,1,0.5,1,1,0.5,1,0.5], inf),
	\envbuf, -1,
	\dur, Pseq([0.1], inf);
).play;
)

// combo1
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, Pseq([Pseq([0.1], 15), 0.2], inf),
	\sndbuf, b,
	\transp, Pseq([ Pseq([1], 7), Prand([1, 0.9], 1) ], inf),
	\pos, Pseq([0, 0.1, 0.2, 0.5, 0.1, 0.1, 0.32, 0.2322], inf) * Prand([1, 2], inf),
	\pan, Pwhite(-0.5, 0.5),
	\amp, Pwhite(0.8, 1),
	\envbuf, -1,
	\dur, 0.15;
).play;

Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, Pseq([1, 2, 1, 2], inf),
	\sndbuf, b,
	\transp, Pseq([1, 1, 1, 1], inf),
	\pos, 0.1155,
	\pan, 0,
	\amp, 0.9,
	\envbuf, -1,
	\dur, 0.5;
).play;


Pbind(
	\instrument, "granular_sampling",
	\trigger, 13,
	\graindur, 4,
	\sndbuf, b,
	\transp, Pwhite(0.9, 1.2),
	\pos, Pseq([0.12, 0.12, 0, 0.13, 0.14], inf) + Pwhite(0, 0.01),
	\pan, 0,
	\amp, 1,
	\envbuf, -1,
	\dur, 0.9,
).play;
)

// shutter
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 4,
	\graindur, 0.05,
	\sndbuf, b,
	\transp, Pwrand([1, 2], [0.9, 0.1], inf),
	\pos, Pxrand([0.8, 0.1, 0.11, 0.12], inf),
	\pan, Pwhite(-0.4, 0.4),
	\amp, 1,
	\envbuf, -1,
	\dur, Pseq([Pseq([1/16], 15), Pseq([1/64, 1/64, 1/32], 1)], inf) * 3,
).play;
)

// shutter2
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 4,
	\graindur, 0.05,
	\sndbuf, b,
	\transp, Pwrand([1, 2], [0.9, 0.1], inf),
	\pos, Pxrand([0.8, 0.1, 0.11, 0.12], inf),
	\pan, Pwhite(-0.4, 0.4),
	\amp, 1,
	\envbuf, -1,
	\dur, Pseq([Pseq([1/16], 15), Pseq([1/64, 1/64, 1/32], 1)], inf) * 2,
).play;
)

// chirp
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 4,
	\graindur, 0.05,
	\sndbuf, b,
	\transp, -24 + Pwrand([1, 2], [0.9, 0.1], inf),
	\pos, Pxrand([0.8, 0.1, 0.5, 0.12], inf),
	\pan, Pwhite(-0.4, 0.4),
	\amp, 1,
	\envbuf, -1,
	\dur, Pseq([Pseq([1/16], 15), Pseq([1/64, 1/64, 1/32], 1)], inf) * 10,
).play;
)

// combo2
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, Pwhite(1, 2),
	\graindur, Pseq([0.3, 0.4, 0.6, 1], inf),
	\sndbuf, b,
	\transp, Prand([1, 1, 1, 1, 1], inf),
	\pos, Prand([0.43, 0.2, 0.7, 0.115, 0.57, 0.19, 0.6265], inf),
	\pan, Pseq([-0.8, -0.5, 0, 0.5, 0.8], inf),
	\amp, Prand([0.5, 1], inf),
	\envbuf, z,
	\dur, Pseq([1, 1, 1, 1, 1, 1, 1, 1, 1], inf);
).play;

Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, Pseq([0.25, 0.566, 0.43, 0.777], inf),
	\sndbuf, b,
	\transp, Pseq([1, 1, 1, 1, 1, 1, 1, 1.5], inf),
	\pos, Pseq([0.25, 0.566, 0.43, 0.777], inf),
	\pan, Pseq([-1, 0, 0, 0, 1, 0, 0, 0], inf), //Pseq([1, 0.9 , 0.8 , 0.7 , 0.6, 0.5, 0.4, 0.3, 0.2, 0.1, 0, -0.9, -0.8, -0.3, -0.6, -0.9, -1, -1, -1, -1], inf),
	\amp, Prand([0.9, 1], inf),
	\envbuf, -1,
	\dur, Pseq([0.25, 0.125, 0.125, 0.6], inf);
).play;

Pbind(
	\instrument, "granular_sampling",
	\trigger, 13,
	\graindur, 4,
	\sndbuf, b,
	\transp, Pwhite(1.5, 3),
	\pos, Pseq([0.89, 0.34, 0.67, 0.55, 0.19], inf) + Pwhite(0, 0.01),
	\pan, -0.8,
	\amp, 0.5,
	\envbuf, -1,
	\dur, 0.9,
).play;
)

// deconstruct
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 13,
	\graindur, 4,
	\sndbuf, b,
	\transp, Pwhite(0.1, 1),
	\pos, Pseq([0.89, 0.34, 0.67, 0.55, 0.19], inf) + Pwhite(0, 0.01),
	\pan, 0,
	\amp, 2,
	\envbuf, -1,
	\dur, 0.5,
).play;
)

// ahhh2
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, 4,
	\sndbuf, b,
	\transp, 0.5,
	\pos, 0.6555,
	\pan, 0,
	\amp, 0.9,
	\envbuf, -1,
	\dur, Pseq([0.125, 0.125, 0.125, 0.125, 0.1, 0.1, 0.1], inf);
).play;
)

// ahhh3
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, 4,
	\sndbuf, b,
	\transp, 0.3,
	\pos, 0.6555,
	\pan, 0,
	\amp, 0.9,
	\envbuf, -1,
	\dur, Pseq([0.125, 0.125, 0.125, 0.125, 0.1, 0.1, 0.1], inf);
).play;
)

// ahhh4
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, 4,
	\sndbuf, b,
	\transp, 0.45,
	\pos, 0.6555,
	\pan, 0,
	\amp, 0.9,
	\envbuf, -1,
	\dur, Pseq([0.125, 0.125, 0.125, 0.125, 0.1, 0.1, 0.1], inf);
).play;
)

// ahhh5
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, 4,
	\sndbuf, b,
	\transp, 0.6,
	\pos, 0.6555,
	\pan, 0,
	\amp, 0.9,
	\envbuf, -1,
	\dur, Pseq([0.125, 0.125, 0.125, 0.125, 0.1, 0.1, 0.1], inf);
).play;
)

// ahhh6
(
Pbind(
	\instrument, "granular_sampling",
	\trigger, 0,
	\graindur, 4,
	\sndbuf, b,
	\transp, 1.8,
	\pos, 0.6555,
	\pan, 0,
	\amp, 0.9,
	\envbuf, -1,
	\dur, Pseq([0.125, 0.125, 0.125, 0.125, 0.1, 0.1, 0.1], inf);
).play;
)