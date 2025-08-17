(
s.waitForBoot({
	Routine{
		SynthDef("sampler",{
			arg buf;
			var snd = Silent.ar;
			Out.ar(0,snd);
		}).send(s);

		s.sync;
		["loaded"].postln;
	}.play;
});
)