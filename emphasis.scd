(
s.waitForBoot({
	SynthDef("microphone",{
		var snd;
		var snd_uncompensated;
		snd = SoundIn.ar(0);
		snd_uncompensated = SoundIn.ar(0);
		snd = BPeakEQ.ar(snd,220,db:8);
		snd = BPeakEQ.ar(snd,400,db:5);
		snd = BPeakEQ.ar(snd,660,db:-4);
		snd = BPeakEQ.ar(snd,4040,db:1);
		Out.ar(4,snd_uncompensated);
		Out.ar(8,snd);
	}).send(s);

	SynthDef("sine",{
		arg out=0, freq=440, db=0;
		var snd;
		snd = SinOsc.ar(freq);
		Out.ar(out, snd * db.dbamp);
	}).send(s);
	SynthDef("noise",{
		arg freq=440, db=0;
		var snd;
		snd = WhiteNoise.ar();
		Out.ar(0,snd * db.dbamp);
	}).send(s);
	s.sync;
	Synth("microphone");
	Synth("sine",[\freq:220,\db:-8]);
	Synth("sine",[\freq:400,\db:-12]);
	Synth("sine",[\freq:660,\db:-2]);
	Synth("sine",[\freq:4040,\db:-8]);
	// Synth("noise",[\freq:4040,\db:]);
	//
	{
		var w = Window("Speaker", Rect(0, 700, 700, 300));
		var f = FreqScopeView(w, w.view.bounds,s);
		f.inBus = 0;
		f.freqMode = 1;
		f.dbRange = 20;
		f.active_(true); // turn it on the first time;
		w.onClose_({ f.kill }); // YOU MUST HAVE THIS
		w.front;
	}.();
	{
		var w = Window("Microphone (uncompensated)", Rect(0, 350, 700, 300));
		var f = FreqScopeView(w, w.view.bounds,s);
		f.inBus = 4;
		f.freqMode = 1;
		f.dbRange = 20;
		f.active_(true); // turn it on the first time;
		w.onClose_({ f.kill }); // YOU MUST HAVE THIS
		w.front;
	}.();
	{
		var w = Window("Microphone (compensated)", Rect(0, 0, 700, 300));
		var f = FreqScopeView(w, w.view.bounds,s);
		f.inBus = 8;
		f.freqMode = 1;
		f.dbRange = 20;
		f.active_(true); // turn it on the first time;
		w.onClose_({ f.kill }); // YOU MUST HAVE THIS
		w.front;
	}.();
})
)




(
s.waitForBoot({
	SynthDef("microphone",{
		var snd;
		var snd_uncompensated;
		snd = SoundIn.ar(0);
		Out.ar(8,snd);
	}).send(s);

	SynthDef("sine",{
		arg out=0, freq=440, db=0;
		var snd;
		snd = SinOsc.ar(freq);
		Out.ar(out, snd * db.dbamp);
	}).send(s);
	SynthDef("noise",{
		arg freq=440, db=0;
		var snd;
		snd = WhiteNoise.ar();
		Out.ar(0,snd * db.dbamp);
	}).send(s);
	s.sync;
	Synth("microphone");
	Synth("sine",[\freq:220,\db:-8,\out:4]);
	Synth("sine",[\freq:400,\db:-12,\out:4]);
	Synth("sine",[\freq:660,\db:-2,\out:4]);
	Synth("sine",[\freq:4040,\db:-8,\out:4]);
	// uncompensated
	Synth("sine",[\freq:220,\db:-8,\out:0]);
	Synth("sine",[\freq:400,\db:-12,\out:0]);
	Synth("sine",[\freq:660,\db:-2,\out:0]);
	Synth("sine",[\freq:4040,\db:-8,\out:0]);
	// compensated
	// Synth("sine",[\freq:220,\db:-8+9,\out:0]);
	// Synth("sine",[\freq:400,\db:-12+5,\out:0]);
	// Synth("sine",[\freq:660,\db:-2,\out:0]);
	// Synth("sine",[\freq:4040,\db:-8+3,\out:0]);
	//
	{
		var w = Window("Audio", Rect(0, 0, 550, 300));
		var f = FreqScopeView(w, w.view.bounds,s);
		f.inBus = 4;
		f.freqMode = 1;
		f.dbRange = 20;
		f.active_(true); // turn it on the first time;
		w.onClose_({ f.kill }); // YOU MUST HAVE THIS
		w.front;
	}.();
	{
		var w = Window("Speaker (uncompensated audio)", Rect(550, 0, 550, 300));
		var f = FreqScopeView(w, w.view.bounds,s);
		f.inBus = 0;
		f.freqMode = 1;
		f.dbRange = 20;
		f.active_(true); // turn it on the first time;
		w.onClose_({ f.kill }); // YOU MUST HAVE THIS
		w.front;
	}.();
	{
		var w = Window("Microphone", Rect(550*2, 0, 550, 300));
		var f = FreqScopeView(w, w.view.bounds,s);
		f.inBus = 8;
		f.freqMode = 1;
		f.dbRange = 20;
		f.active_(true); // turn it on the first time;
		w.onClose_({ f.kill }); // YOU MUST HAVE THIS
		w.front;
	}.();
})
)



(
s.waitForBoot({
	SynthDef("microphone",{
		var snd;
		var snd_uncompensated;
		snd = SoundIn.ar(0);
		Out.ar(8,snd);
	}).send(s);

	SynthDef("sine",{
		arg out=0, freq=440, db=0;
		var snd;
		snd = SinOsc.ar(freq);
		Out.ar(out, snd * db.dbamp);
	}).send(s);
	SynthDef("noise",{
		arg freq=440, db=0;
		var snd;
		snd = WhiteNoise.ar();
		Out.ar(0,snd * db.dbamp);
	}).send(s);
	s.sync;
	Synth("microphone");
	Synth("sine",[\freq:220,\db:-8,\out:4]);
	Synth("sine",[\freq:400,\db:-12,\out:4]);
	Synth("sine",[\freq:660,\db:-2,\out:4]);
	Synth("sine",[\freq:4040,\db:-8,\out:4]);
	// uncompensated
	// Synth("sine",[\freq:220,\db:-8,\out:0]);
	// Synth("sine",[\freq:400,\db:-12,\out:0]);
	// Synth("sine",[\freq:660,\db:-2,\out:0]);
	// Synth("sine",[\freq:4040,\db:-8,\out:0]);
	// compensated
	Synth("sine",[\freq:220,\db:-8+9,\out:0]);
	Synth("sine",[\freq:400,\db:-12+5,\out:0]);
	Synth("sine",[\freq:660,\db:-2,\out:0]);
	Synth("sine",[\freq:4040,\db:-8+3,\out:0]);
	//
	{
		var w = Window("Audio", Rect(0, 0, 550, 300));
		var f = FreqScopeView(w, w.view.bounds,s);
		f.inBus = 4;
		f.freqMode = 1;
		f.dbRange = 20;
		f.active_(true); // turn it on the first time;
		w.onClose_({ f.kill }); // YOU MUST HAVE THIS
		w.front;
	}.();
	{
		var w = Window("Speaker (compensated audio)", Rect(550, 0, 550, 300));
		var f = FreqScopeView(w, w.view.bounds,s);
		f.inBus = 0;
		f.freqMode = 1;
		f.dbRange = 20;
		f.active_(true); // turn it on the first time;
		w.onClose_({ f.kill }); // YOU MUST HAVE THIS
		w.front;
	}.();
	{
		var w = Window("Microphone", Rect(1100, 0, 550, 300));
		var f = FreqScopeView(w, w.view.bounds,s);
		f.inBus = 8;
		f.freqMode = 1;
		f.dbRange = 20;
		f.active_(true); // turn it on the first time;
		w.onClose_({ f.kill }); // YOU MUST HAVE THIS
		w.front;
	}.();
})
)








