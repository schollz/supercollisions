(
{
	arg hz=220, amp=0.5;
	var snd,snd2,note,noteNext,noteArray,basshz,basshz2,bass;
	var noteFreq=LinExp.kr(VarLag.kr(LFNoise0.kr(1/4),4),-1,1,0.1,128);
	var eigthNote=Impulse.kr(noteFreq);
	var cmajor=Scale.major.degrees;
	var slowsine=VarLag.kr(LFNoise0.kr(1/2),2).range(-1,1);
	var detune=0.05;
	note=hz.cpsmidi;
	noteArray=Demand.kr(Dust.kr(0.5),0,Dxrand([[0,4,7],[0,4,9],[-1,4,7],[2,5,9],[4,7,12],[4,9,12]],inf));
	noteNext=note+Demand.kr(eigthNote,0,Dseq(noteArray,inf));
	snd=SinOsc.ar((noteNext+SinOsc.kr(rrand(0.1,0.5)).range(detune.neg,detune)).midicps,mul:SinOsc.kr(rrand(0.1,0.3)).range(0.2,0.8));
	snd=snd+SinOsc.ar((12+noteNext+SinOsc.kr(rrand(0.1,0.5)).range(detune.neg,detune)).midicps,mul:SinOsc.kr(rrand(0.1,0.3)).range(0.2,0.8));
	snd=snd+SinOsc.ar((12.neg+noteNext+SinOsc.kr(rrand(0.1,0.5)).range(detune.neg,detune)).midicps,mul:SinOsc.kr(rrand(0.1,0.3)).range(0.2,0.8));
	snd=snd*EnvGen.ar(Env.perc(
		LinExp.kr(slowsine,-1,1,0.02/noteFreq,0.98/noteFreq),
		LinExp.kr(slowsine,-1,1,0.98/noteFreq,0.02/noteFreq)
	),eigthNote);
	snd=snd*0.1;

	snd=snd.tanh;

	snd=MoogLadder.ar(snd,LinExp.kr(VarLag.kr(LFNoise0.kr(1/4),4),-1,1,4000,8000));
	snd=HPF.ar(snd,20);



	// reverb
	snd2 = DelayN.ar(snd, 0.03, 0.03);
	snd2 = CombN.ar(snd2, 0.1, {Rand(0.01,0.099)}!32, 4);
	snd2 = SplayAz.ar(2, snd2);
	snd2 = LPF.ar(snd2, 1500);
	5.do{snd2 = AllpassN.ar(snd2, 0.1, {Rand(0.01,0.099)}!2, 3)};
	snd2 = LPF.ar(snd2, 1500);
	snd2 = LeakDC.ar(snd2);
	snd = snd + (0.1*snd2);


	Out.ar(0,snd*amp);
}.play;
)

[0,0,1]+[0,2,0]