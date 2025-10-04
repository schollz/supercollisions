// Simple 303-style synth (no sequencing)
(
SynthDef(\simple303, { |out=0, freq=110, waveMix=0.2, cutoff=2000, res=0.6, gate=1|
	var osc, env, fenv, filt;

	// oscillator: mix between saw and pulse
	osc = Mix([
		DPW4Saw.ar(freq, 0.5),
		Pulse.ar(freq, 0.5)
	] * [1 - waveMix, waveMix]);

	// amplitude envelope
	env = EnvGen.kr(Env.adsr(0.01, 0.1, 0.5, 0.2), gate, doneAction: 2);

	// filter envelope
	fenv = EnvGen.kr(Env([0, 1, 0], [0.01, 0.3]), gate);

	// resonant lowpass filter
	filt = RLPF.ar(
		osc,
		cutoff + (fenv * (cutoff * 4)), // envelope modulates cutoff
		res
	);
	// filt = MoogLadder.ar(		osc,
	// 	cutoff + (fenv * (cutoff * 4)), // envelope modulates cutoff
	// 	res
	// );

	// output with mild saturation
	filt = tanh(filt * 2) * env * 0.4;
	Out.ar(out, filt!2);
}).add;
)

// Example usage:
x = Synth(\simple303, [\freq, 110, \cutoff, 1500, \res, 0.1]);

// Change parameters in realtime:
x.set(\freq, 220, \cutoff, 2500);
x.set(\waveMix, 0.5, \res, 0.8);

// Release
x.set(\gate, 0);



(
SynthDef(\acid303, {
	|out=0, freq=110, waveMix=0.2, cutoff=200, res=0.6, gate=1,
	accent=0, glide=0.05, drive=0.6, envAmt=2.5, t_trig=1,

	var osc, env, fenv, filt, glideFreq;
	glideFreq = Lag.kr(freq, glide);

	// Osc mix
	osc = Mix([
		DPW4Saw.ar(glideFreq),
		Pulse.ar(glideFreq, 0.5)
	] * [1 - waveMix, waveMix]);

	// Envelope
	env = EnvGen.kr(Env.adsr(0.01, 0.1, 0.5, 0.35), gate, doneAction: 2);
	fenv = EnvGen.kr(Env.perc(0.001, 0.3),t_trig) * envAmt * (1 + accent);

	// Filter: smooth analog squelch
	filt = DFM1.ar(
		tanh(osc * (1.5 + accent)), // drive the input
		MouseY.kr(100,20000,1) * (1 + fenv)* ,
		MouseX.kr(0.1,4),
		drive
	);

	Out.ar(out, tanh(filt * 2) * env * 0.4 ! 2);
}).add;
)




(
~acidSeq = Pmono(
	\acid303,   // same synthdef

	\dur, Pseq([0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25], inf) / 2.3,

	\degree, Pseq([0, 3, 7, 10, 12, 15, 7, 10].scramble, inf),
	\scale, Scale.minor,

	\octave, Pseq([2, 2, 2, 2, 3, 2, 3, 2], inf),

	\envAmt, Pwhite(2.0, 3.5, inf),
	\res, Pseq([0.5, 0.5, 0.9, 1.1], inf),

	\accent, Pwrand([0, 1], [0.75, 0.25].normalizeSum, inf),

	// this now works properly!
	\glide, Pseq([0.05, 0.05, 0.1, 0.2, 0.05, 0.05, 0.15,1,0,0,0,0,0], inf),

	\drive, Pexprand(0.5, 0.9, inf),
	\waveMix, Pseq([0, 0.5, 1, 1, 0.5, 0.2, 0.1], inf),
	\amp, Pexprand(0.25, 0.4, inf),
	\t_trig, 1,
).play;
)

(
~acidSeq = Pbind(
	\instrument, \acid303,

	// 303 step length
	\dur, Pseq([0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25], inf)/2.3,

	// classic C minor / F minor riff area
	\degree, Pseq([0, 3, 7, 10, 12, 15, 7, 10].scramble, inf),
	\scale, Scale.minor,

	// random octave jumps
	\octave, Pseq([2,2,2,2,2,2,3,2,3,2,2,2,2],inf),

	// cutoff envelope depth
	\envAmt, Pwhite(2.0, 3.5, inf),

	// random cutoff and resonance movement
	\cutoff, Pexprand(800, 3000, inf),
	\res, Pseq([0.5,0.5,0.9,1.1],inf),

	// accent probability (adds bite and volume)
	\accent, Pwrand([0, 1], [0.75, 0.25].normalizeSum, inf),

	// // slide probability (glide between notes)
	\glide,Pseq([0,0,0,0.2,0,0,0.5],inf),

	// drive intensity
	\drive, Pexprand(0.5, 0.9, inf),

	// wave mix between saw and pulse
	\waveMix, Pseq([0,0.5,1,1,1,1,0.5,0.2,0,0,0,0.1],inf),

	// amplitude slightly reduced for dynamics
	\amp, Pexprand(0.2, 0.4, inf)
).play;
)





(
SynthDef(\acid303, {
	|out=0, freq=110, waveMix=0.2, cutoff=800, res=0.7, gate=1,
	 accent=0, glide=0.05, drive=0.8, envAmt=3.0, t_trig=1, amp=0.6|

	var osc, env, fenv, filt, glideFreq, preDrive, postDrive;

	// Smooth glide
	glideFreq = Lag.kr(freq, glide);

	// --- Oscillator mix ---
	osc = Mix([
		DPW4Saw.ar(glideFreq),
		Pulse.ar(glideFreq, 0.5)
	] * [1 - waveMix, waveMix]);

	// --- Envelopes (retriggered) ---
	env = EnvGen.ar(Env.perc(0.005, 0.5), t_trig);
	fenv = EnvGen.kr(Env.perc(0.001, 0.20), t_trig)
		* envAmt * (1 + accent * 1.4);

	// --- Pre-filter drive / tone balance ---
	preDrive = tanh(osc * (2.5 + accent)); // hotter, punchier

	// --- Filter (DFM1 = nice analog model) ---
	filt = DFM1.ar(
		preDrive,
		(cutoff * (1 + fenv)).clip(80, 15000), // safe range
		(res ).clip(0.2,3.0),
		drive
	);

	// --- Post-filter shaping & slight high boost ---
	postDrive = HPF.ar(tanh(filt * (3 + accent)), 80);

	// --- Output ---
	Out.ar(out, postDrive * env * amp ! 2);
}).add;
)


(
~acidSeq = Pmono(
	\acid303,

	// rhythm pattern
	\dur, Pseq(Array.fill(16, 60/120/4), inf),
	\legato, 0.9,

	// one random 16-note phrase from first 10 notes of C minor
	\degree, Pseq({ 16.collect { [0,2,3,5,7,8,10,12,14,15].choose } }.value - 5, inf),
	\scale, Scale.minor,
	\octave, Pseq([3], inf),

	// each param: one random 16-step pattern, repeated forever
	\envAmt,  Pseq({ 16.collect { 2.0 } }.value, inf),
	\cutoff,  Pseq({ 16.collect { 200 } }.value, inf),
	\res,     Pseq({ 16.collect { 2.0 } }.value, inf),
	// \accent,  Pseq({ 16.collect { 1.0 } }.value, inf),
	// \accent,  Pseq({ 16.collect { [0, 1].wchoose([0.7, 0.3]) } }.value, inf),
	\glide,   Pseq({ 16.collect { 0.1 } }.value, inf),
	\drive,   Pseq({ 16.collect { 2.5 } }.value, inf),
	\waveMix, Pseq({ 16.collect { 0.5 } }.value, inf),

	\amp, 0.8,
	\t_trig, 1
).play;
)


(
~acidSeq = Pmono(
	\acid303,

	// rhythm pattern
	\dur, Pseq(Array.fill(16, 60/120/4), inf),
	\legato, 0.9,

	// one random 16-note phrase from first 10 notes of C minor
	\degree, Pseq({ 16.collect { [0,2,3,5,7,8,10,12,14,15].choose } }.value - 5, inf),
	\scale, Scale.minor,
	\octave, Pseq([3], inf),

	// each param: one random 16-step pattern, repeated forever
	\envAmt,  Pseq({ 16.collect { rrand(2.5, 4.0) } }.value, inf),
	\cutoff,  Pseq({ 16.collect { exprand(100, 4000) } }.value, inf),
	\res,     Pseq({ 16.collect { [0.6, 0.7, 0.9, 1.0].choose } }.value, inf),
	\accent,  Pseq({ 16.collect { [0, 1].wchoose([0.7, 0.3]) } }.value, inf),
	\glide,   Pseq({ 16.collect { [0.05, 0.1, 0.2, 0.0,1.0].choose } }.value, inf),
	\drive,   Pseq({ 16.collect { exprand(0.6, 1.0) } }.value, inf),
	\waveMix, Pseq({ 16.collect { rrand(0.0, 1.0) } }.value, inf),

	\amp, 0.8,
	\t_trig, 1
).play;
)


