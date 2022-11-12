(
{
	arg hz=440,amp=1.0;
	var note=hz.cpsmidi;
	var snd;
	var airports=[
		[5,7,4,2,0,12,7,5,7,4,2,0],
		[5,7,4,2,0,12,4,7,5,0],
		[-5,2,0,4,7,12,5,2,7,4,0,7,2,5,5,2,4,0],
		[7,7,2,4,4,4,2,0,7,0,0],
	];
	var planes=[
		[0,4,7,12],
		[4,7,11,16],
		[-3,0,4,7],
		[-3,0,5,9],
	];
	var seq,seqnote,notepulse;
	var planeseq,planenotes,planeenv,planenotechange;
// TODO a way to change chords?
	// have the planenotes trigger a inverse envelope
	planenotechange=Dust.kr(1/30)+Impulse.kr(0);
	planeenv=1-EnvGen.kr(Env.perc(3,10,0.98),planenotechange);
	planenotes=Demand.kr(TDelay.kr(planenotechange,3),0,Dxrand(planes,inf));
	notepulse=1;
	notepulse=Impulse.kr(TChoose.kr(Dust.kr(notepulse)+Impulse.kr(0),[0.02,0.05,1,2,0.5,0.25,2]/2)).poll;
	seq=Demand.kr(Dust.kr(0.1)+Impulse.kr(0),0,Dxrand(airports,inf));
	seqnote=Demand.kr(notepulse,0,Dseq(seq,inf)).poll;
	snd=SinOsc.ar((note-24).midicps,mul:0.1);
	planenotes.poll;
	snd=snd+Mix.ar(Array.fill(8,{arg i;
		var snd;
		snd=SawDPW.ar((note+planenotes[i%4]+Select.kr(DC.kr(i%4)<1,[24.neg,36.neg])).midicps,mul:0.9);
		snd=LPF.ar(snd,LinExp.kr(SinOsc.kr(rrand(1/30,1/10),rrand(0,2*pi)),-1,1,hz,hz*5));
		snd=DelayC.ar(snd, rrand(0.01,0.03), LFNoise1.kr(Rand(5,10),0.01,0.02)/15 );
		Pan2.ar(snd,VarLag.kr(LFNoise0.kr(1/3),3,warp:\sine))/10
	}));
	snd=MoogLadder.ar(snd.tanh,LinExp.kr(VarLag.kr(LFNoise0.kr(1/6),6,warp:\sine),-1,1,hz*2,hz*60));
	snd=snd+(0.7*DynKlank.ar(`[[(note+planenotes[0]).midicps, (note+planenotes[1]).midicps, (note+planenotes[2]).midicps, (note+planenotes[3]).midicps], nil, [1, 1, 1, 1]], PinkNoise.ar([0.004, 0.004])));
	snd=snd*planeenv;
	snd=snd+(
		EnvGen.ar(Env.perc(release:4),notepulse)*
		MoogFF.ar(Pulse.ar((note+seqnote).midicps,mul:0.7),(note).midicps*1.2)
	);
	snd=LPF.ar(snd,(note+36).midicps);
	snd=HPF.ar(snd,120);
	snd*amp;
}.play;
)

-5 -3  -1 0 2 4  5 7 9 11 12
A   B  C# D E F# G A B C# D

5 7 4  2 0 12 7 5 7 4  2 0
G A F# E D D* A G A F# E D

5 7 4  2 0 12 4  7 5 0
G A F# E D D* F# A G D

-5 2 0 4  7 12 5 2 7 4  0 7 2 5 5 2 4  0
A  E D F# A D* G E A F# D A E G G E F# D

7 7 2 4  4  4  2 0 7 0 0
A A E F# F# F# E D A D D