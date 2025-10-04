(
// Extended supersaw with vibrato + FM
SynthDef(\supersaw, { |out = 0, freq = 440, detune = 0.2, spread = 0.6,
    atk = 0.01, dec = 0.1, sus = 0.6, rel = 0.3, amp = 0.3, gate = 1,
    vibrRate = 6, vibrDepth = 0.2, fmFreq = 0, fmIndex = 0|

    var sig, env, gains, pans, freqs;
    var unison = 7; // fixed voice count (build-time constant)
    var vibrLFO, fmSignal;

    //------------------------
    // 1. Vibrato (slow LFO)
    //------------------------
    // vibrDepth is in semitones; convert to frequency multiplier
    vibrLFO = SinOsc.kr(vibrRate).range(-1, 1) * (2 ** (vibrDepth / 12) - 1);

    //------------------------
    // 2. FM (audio-rate modulator)
    //------------------------
    // classic FM: modulate carrier frequency by another oscillator
    fmSignal = SinOsc.ar(fmFreq) * fmIndex * freq;

    //------------------------
    // 3. Detuned unison voices
    //------------------------
    freqs = Array.fill(unison, { |i|
        var det = ((i / (unison - 1)) - 0.5) * detune; // ±detune/2 semitones
        (freq + fmSignal) * (1 + vibrLFO) * (2 ** (det / 12));
    });

    pans = Array.fill(unison, { |i|
        var side = (i % 2 == 0).if({ -1 }, { 1 });
        side * spread;
    });

    gains = 1 / sqrt(unison);

    sig = Mix.fill(unison, { |i|
        Pan2.ar(Saw.ar(freqs[i], gains), pans[i]);
    });

    //------------------------
    // 4. Envelope and output
    //------------------------
    env = Env.adsr(atk, dec, sus, rel).kr(gate, doneAction: 2);

	sig = MoogLadder.ar(sig,XLine.kr(200,10000,1));
	Out.ar(out, sig * env * amp * 0.9);
}).add;
)



(
SynthDef(\supersaw_jslike, { |out = 0, freq = 440, detune = 0.2, spread = 0.6,
    atk = 0.01, dec = 0.1, sus = 0.6, rel = 0.3, amp = 0.3, gate = 1,
    vibrRate = 6, vibrDepth = 0.3, fmFreq = 0, fmIndex = 0, duration=1,
    drive = 1.5, q = 0.8, cutoff = 8000, crush = 0, coarse = 1|

    var sig, env, freqs, vibrLFO, fm, unison = 7;

    // Vibrato in semitones -> frequency ratio
    vibrLFO = LFTri.kr(vibrRate).range(-1, 1) * (2 ** (vibrDepth / 12) - 1);

    // FM signal (scaled to Hz)
    fm = SinOsc.ar(fmFreq) * fmIndex * freq;

    // Unison voices with random phases
    freqs = Array.fill(unison, { |i|
        var det = ((i / (unison - 1)) - 0.5) * detune; // ±detune/2
		(freq + fm) * (1 + (LFTri.kr(vibrRate,Rand(0,1)).range(-1, 1) * (2 ** (vibrDepth / 12) - 1))) * (2 ** (det / 12));
    });

    sig = Mix.fill(unison, { |i|
        var osc = SawDPW.ar(freqs[i], Rand(0, 1)); // random phase
        Pan2.ar(osc, ((i % 2) * 2 - 1) * spread);
    }) / sqrt(unison);


    // Envelope
	env = EnvGen.ar(Env.adsr(atk, dec, sus, rel), gate, doneAction:2);

	// Moog Ladder filter with drive
	sig = MoogLadder.ar(sig * drive, XLine.kr(cutoff,18000,duration)*env+10) * (1 / drive);


    Out.ar(out, sig * env * amp * 0.9);
}).add;
SynthDef("out",{
	var snd = In.ar(0,2);
	var rev = Fverb.ar(snd[0],snd[1],200,tail_density: LFNoise2.kr(1/3).range(50,90),decay: LFNoise2.kr(1/3).range(50,70));

	snd = SelectX.ar(0.8,[snd,rev]);
	//
	// snd = RHPF.ar(snd,60,0.303);

	//snd = AnalogTape.ar(snd,1.5,0.8,0.8,2);

	ReplaceOut.ar(0,snd);
}).add;
)

x = Synth.tail(Server.default,"out");


(
// simple sequencer for supersaw_jslike
Pdef(\seq,
    Pbind(
        \instrument, \supersaw_jslike,
		 \addAction, \addToHead,     // insert at head
        \amp, 0.25,
        \detune, 0.5,
        \spread, 0.8,
        \drive, 1.5,
        \q, 0.8,
        \rel,2.0,
		\atk, 0.01,
        \cutoff, 200,
        \duration, 0.1,
		\fmFreq,200,
		\fmIndex,0.2,
		\dur, 2,
        \sustain, 1.9,
		\duration, 2,
		\freq, Pseq([[33,60], [31,62], [29,57], [24,55]].midicps, inf)
    )
).play;
)

\a1.midicps

