(
s.waitForBoot({
	SynthDef("sine",{
		arg note;
		var snd=Pulse.ar(note.midicps,SinOsc.kr(Rand(1,3),Rand(0,pi)).range(0.3,0.7));
		var env=EnvGen.ar(Env.perc(1,3,1,[4,-4]),doneAction:2);
		snd=snd*env/16;
		snd=RLPF.ar(snd,note.midicps*6,0.8);
		Out.ar(0,snd);
	}).send(s);
	s.sync;
	SynthDef("out",{
		var snd=In.ar(0,2);
		// uncomment this if you have Fverb
		snd=SelectX.ar(0.8,[snd,Fverb.ar(snd[0],snd[1],100,decay:VarLag.kr(LFNoise0.kr(1/3),3).range(50,100))]);
		ReplaceOut.ar(0,snd);
	}).send(s);
	s.sync;
	Synth.tail(s,"out");
	Routine {
		var seeds;
		var scale=[ 0, 2, 4, 5, 7, 9, 11 ];
		scale=scale++(scale+12);
		scale=scale++(scale+24);
		scale=scale++(scale+36);
		Routine {
			inf.do({ arg j;
				var spaces;
				var hm;
				if (j.mod(16)<1,{
					seeds=[100.rand,100.rand,100.rand,100.rand].postln;
					//seeds=[ 81, 29, 24, 23 ]; // THIS IS A NICE SEED!
				});
				thisThread.randSeed = seeds[j.mod(seeds.size)];
				if (10.rand<10,{
					spaces={ 1+3.rand }!4;
					hm=[[4,3,2],[3,2,1],[2,2,3],[3,4,5]].choose.scramble;
					spaces[0]=8.rand;
					spaces[1]=hm[0];
					spaces[2]=hm[1];
					spaces[3]=hm[2];
					spaces.do({arg v,i;
						if (i>0,{
							spaces[i]=spaces[i]+spaces[i-1];
						});
						Synth.head(s,"sine",[\note,scale[spaces[i]]+48]);
						[i,v,spaces[i]].postln;
					});
				});
				(1.5+(0.25*7.rand)).sleep;
			});
		}.play;
	}.play;
});
)
