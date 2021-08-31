// orignal
// https://ia600202.us.archive.org/29/items/sc140/sc140_sourcecode.txt
// 16
// Batuhan Bozkurt
// play{AllpassC.ar(SinOsc.ar(55).tanh,0.4,TExpRand.ar(2e-4, 0.4,Impulse.ar(8)).round([2e-3,4e-3]),2)};// #supercollider with bass please...

(
{
	var snd,freq,pulse, chords, chord;
	//            Am        F          C          Em
	// chords=Dseq([[33,36,40],[33,36,41],[31,36,40],[31,35,40]],inf);
	chords=Dseq([[33,33,40],[29,29,36],[36,36,43],[28,28,35]],inf);
	chord=Demand.kr(Impulse.kr(86/60/4),0,chords);
	freq=TChoose.kr(Impulse.kr(1.4333),chord.midicps);
	snd=SinOsc.ar(freq).tanh;
	snd=AllpassC.ar(snd,0.4,TExpRand.ar(2e-4, 0.4,Impulse.ar(8)).poll.round([2e-3,4e-3]),2);
	//snd=snd+AllpassC.ar(snd,0.4,Demand.kr(Impulse.kr(8),0,Dseq([0.00421835,0.00460017,0.000295328,0.19721,0.101522,0.00029477,0.320863,0.001676,0.01069,0.00066,0.0011393,0.01772],inf)).round([2e-3,4e-3]),2);
	snd=LPF.ar(snd/2,VarLag.kr(LFNoise0.kr(Dust.kr(1)),1,warp:\sine).range(300,1000));
	snd=snd+PMOsc.ar([freq,freq*1.02],freq*0.98,3,mul:0.0);
	snd=Compander.ar(snd,snd);
	snd=HPF.ar(snd,70);
	Out.ar(0,snd.tanh*(-5.dbamp))
}.play;
)


(
{
	var s;
s=TExpRand.ar(2e-4, 0.4,Impulse.kr(8));
	Silent.ar();
}.play(0.25)
)