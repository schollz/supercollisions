(
s.waitForBoot({
	var scale;

	SynthDef("padVoice",{
		// ARGUMENTS (leave this as is)
		arg note=60,amp=0.5,out=0,attack=1,decay=1;
		var snd = Silent.ar(2); // initialize the sound to silence
		var freq = note.midicps; // midi note converts to frequency using .midicps
		var env = EnvGen.ar(Env.perc(attack,decay,amp,[4,4]),doneAction:2); // envelope
		var pan = LFNoise2.kr(1/Rand(3,6)).range(-0.5,0.5); // random modulation for panning
		var detune = LFNoise2.kr(1/Rand(1,5)).range(-0.1,0.1); // random modulation for detuning or anything

		// ----- MAKE YOUR OWN SYNTH HERE ----- //

		// simple sine wave
		//
		// snd = SinOsc.ar(freq);

		// simple filtered saw wave
		//
		// snd = Saw.ar(freq);
		// snd = LPF.ar(snd, freq*8);


		// filtered detuned saw wave
		// with opening filter
		//
		snd = Saw.ar([note-detune,note+detune].midicps);
		snd = MoogFF.ar(snd,
			LinExp.kr(0.01+EnvGen.kr(Env.perc(attack,decay)),0.01,1.01,freq,ExpRand(freq*2,20000)));

		// sine with phase modulation feedack
		// feedback is randomly modulated
		//
		// snd = SinOscFB.ar(freq, LFNoise2.kr(1/3).range(0,1));

		// a switch can randomly switch between
		// snd = SelectX.ar(LFNoise2.kr(1).range(0,1),[
		// 	LFTri.ar(freq),
		// 	SinOsc.ar(freq),
		// ]);


		// ----- ------------------------ ----- //



		// panning
		snd=snd!2;
		snd = Balance2.ar(snd[0],snd[1],pan);
		// for drawing
		SendReply.kr(Impulse.kr(25),"/sunposition",[\sector.kr(0),note,env,pan,detune.abs]);
		// final output
		Out.ar(out,snd*env/12);
	}).send(s);

	// // effects
	SynthDef("padOutput",{
		arg amp=1.0;
		var snd=In.ar(0,2);
		snd=HPF.ar(snd,30);
		snd=AnalogTape.ar(snd,0.9,0.9,0.8,2);
		snd=SelectX.ar(LFNoise2.kr(1/4).range(0.5,0.9),[snd,Fverb.ar(snd[0],snd[1],50,decay:LFNoise2.kr(1/4).range(70,90))]);
		ReplaceOut.ar(0,snd*Lag.kr(amp));
	}).send(s);


	// CHANGE THIS!
	// set the scale
	scale = Scale.major;
	// scale = Scale.minor;
	// scale = Scale.dorian;
	// ... see more at ScaleLP

	// set the four

	// the Sun plays random notes from the scale
	b=Sun.new(s,
		argSynName:"padVoice",
		argSynOutput:"padOutput",
		argScale:scale,
		argTimes:[10,7,5,2], // <--- CHANGE THIS! these numbers correspond to the durations for the south, east, west, and north sectors
		argNums:[1,2,3,1] // <--- CHANGE THIS! these numbers correspond to the number of voices for the south, east, west, and north sectors
	);
	b.gui;
})
)
