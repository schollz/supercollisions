(
// s.options.memSize = 32*8192;
s.waitForBoot({
	Routine {
		SynthDef("thx",{
			arg noteFinal=72,db=0;
			var timeScale = 1;
			var noteInitial = Rand(200,400).cpsmidi;
			var noteRandomization = EnvGen.ar(Env.new([1,1,0],[10,1],curve:\welch),timeScale:timeScale);
			var noteMove = EnvGen.ar(Env.new([0,1],[12],curve:\sine),gate:noteRandomization<0.01,timeScale:timeScale);
			var notePlayed;
			var note = (noteInitial + (noteRandomization* LFNoise2.kr(1/2).range(-1,1)) + (noteMove* (noteFinal-noteInitial))) ;
			var snd = Saw.ar(note.midicps);
			// var snd = SinOscFB.ar(note.midicps,LFNoise2.kr(1/3).range(0,1));
			snd = LPF.ar(snd,Rand(90,140).midicps);
			snd = Pan2.ar(snd,Rand(-0.5,0.5));
			snd = snd * EnvGen.ar(Env.new([0,1],[1]));
			snd = snd * EnvGen.ar(Env.new([-24,-12,0,0,-96],[14,8,12,2]),doneAction:2).dbamp.poll;
			Out.ar(0,snd*24.neg.dbamp);
		}).add;

		SynthDef("out",{
			var snd = In.ar(0,2);
			var sndr = Fverb.ar(snd[0],snd[1],200,tail_density:LFNoise2.kr(1/3).range(60,90),decay:LFNoise2.kr(1/3).range(50,90));
			snd = SelectX.ar(LFNoise2.kr(1/3).range(0.6,0.8),[snd,sndr]);

			ReplaceOut.ar(0,snd);
		}).add;

		s.sync;

		// https://www.johndcook.com/blog/2018/06/12/mathematics-of-deep-note/
		// D1, D2, A2, D3, A3, D4, A4, D5, A5, D6, and F#6
		~thxNotes = [26,38,45,50,57,62,69,74,81,86,90];
		Synth.tail(s,"out");
		~thxNotes.do({ arg v;
			if (v<60,{
				// 2 voices
				Synth.head(s,"thx",[\noteFinal,v]);
				Synth.head(s,"thx",[\noteFinal,v-12]);
				Synth.head(s,"thx",[\noteFinal,v-24]);
			},{
				// 3 voices, slightly detuneds
				Synth("thx",[\noteFinal,v+rrand(-0.1,0.1)]);
				Synth("thx",[\noteFinal,v+rrand(-0.1,0.1)]);
				Synth("thx",[\noteFinal,12+v+rrand(-0.1,0.1)]);
			});
		});

	}.play;
});
)
