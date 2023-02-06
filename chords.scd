(
s.waitForBoot({
	SynthDef("sine",{
		arg note;
		var snd=SinOsc.ar([note-0.05,note+0.02].midicps);
		var env=EnvGen.ar(Env.perc(0.005,1),doneAction:2);
		snd=snd*env/8;
		Out.ar(0,snd);
	}).send(s);
	s.sync;
	Routine {
		// TODO: if root note is B or E then the available spacings change
		var seeds=[10.rand,10.rand,10.rand,10.rand];
		var scale=[ 0, 2, 4, 5, 7, 9, 11 ];
		scale=scale++(scale+12);
		scale=scale++(scale+24);
		scale=scale++(scale+36);
		Routine {
			inf.do({ arg j;
				var spaces;
				if (j.mod(16)<1,{
					seeds=[100.rand,100.rand,100.rand,100.rand];
				});
				thisThread.randSeed = seeds[j.mod(seeds.size)];
				if (10.rand<8,{
				spaces={ 1+4.rand }!5;
				spaces.do({arg v,i;
					if (i>0,{
						spaces[i]=spaces[i]+spaces[i-1];
					});
					[i,v,spaces[i]].postln;
					Synth.new("sine",[\note,scale[spaces[i]]+60]);
				});
				});
				(0.75).sleep;
				if (10.rand<6,{
					spaces={ 2+4.rand }!5;
					spaces.do({arg v,i;
						if (i>0,{
							spaces[i]=spaces[i]+spaces[i-1];
						});
						[i,v,spaces[i]].postln;
						Synth.new("sine",[\note,scale[spaces[i]]+60]);
					});
				});
				(0.25).sleep;
			});
		}.play;
	}.play;
});
)